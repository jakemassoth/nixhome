#!/usr/bin/env node

import { spawn } from "node:child_process";
import { closeSync, existsSync, mkdirSync, openSync, readFileSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import puppeteer from "puppeteer-core";

const __filename = fileURLToPath(import.meta.url);
// A dedicated subdirectory, not `~/.cache/browser-tools` itself: that path is
// Chrome's --user-data-dir (see browser-start.js), and state/log files don't
// belong mixed into a browser profile directory.
const STATE_DIR = join(homedir(), ".cache", "browser-tools-recorder");
const STATE_FILE = join(STATE_DIR, "recording.json");
const LOG_FILE = join(STATE_DIR, "recording.log");

const [cmd, ...args] = process.argv.slice(2);

if (cmd === "--worker") {
	await runWorker(args[0]);
} else if (cmd === "start") {
	await start(args);
} else if (cmd === "stop") {
	await stop();
} else {
	usage();
}

function usage() {
	console.log("Usage: browser-record.js <start|stop> [--output <path>]");
	console.log("\nExamples:");
	console.log("  browser-record.js start                    # Record the active tab to a temp .webm file");
	console.log("  browser-record.js start --output demo.webm # Record to a specific file");
	console.log("  browser-record.js stop                     # Stop recording and print the file path");
	process.exit(1);
}

function isRunning(pid) {
	try {
		process.kill(pid, 0);
		return true;
	} catch {
		return false;
	}
}

async function start(args) {
	mkdirSync(STATE_DIR, { recursive: true });

	if (existsSync(STATE_FILE)) {
		const state = JSON.parse(readFileSync(STATE_FILE, "utf8"));
		if (isRunning(state.pid)) {
			console.error(`✗ Recording already in progress: ${state.path}`);
			console.error("  Run: browser-record.js stop");
			process.exit(1);
		}
		unlinkSync(STATE_FILE);
	}

	const outputIndex = args.indexOf("--output");
	const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
	const outputPath = outputIndex !== -1 ? args[outputIndex + 1] : join(tmpdir(), `recording-${timestamp}.webm`);
	mkdirSync(dirname(outputPath), { recursive: true });

	// The recorder must outlive this short-lived CLI invocation, so the
	// actual screencast runs in a detached worker process controlled via
	// start/stop and a pid file.
	const logFd = openSync(LOG_FILE, "w");
	const worker = spawn(process.execPath, [__filename, "--worker", outputPath], {
		detached: true,
		stdio: ["ignore", logFd, logFd],
	});
	closeSync(logFd);
	worker.unref();

	// page.screencast() only resolves once the first frame arrives, so a
	// short wait is enough to know whether the worker actually started.
	await new Promise((r) => setTimeout(r, 2000));

	if (!isRunning(worker.pid)) {
		const log = existsSync(LOG_FILE) ? readFileSync(LOG_FILE, "utf8").trim() : "";
		console.error(`✗ Failed to start recording${log ? `: ${log}` : ""}`);
		process.exit(1);
	}

	writeFileSync(STATE_FILE, JSON.stringify({ pid: worker.pid, path: outputPath }));
	console.log(`✓ Recording started: ${outputPath}`);
	console.log("  Run: browser-record.js stop");
}

async function stop() {
	if (!existsSync(STATE_FILE)) {
		console.error("✗ No recording in progress");
		console.error("  Run: browser-record.js start");
		process.exit(1);
	}

	const state = JSON.parse(readFileSync(STATE_FILE, "utf8"));

	if (!isRunning(state.pid)) {
		unlinkSync(STATE_FILE);
		console.error("✗ Recording process is no longer running");
		process.exit(1);
	}

	// SIGTERM lets the worker flush the last frame and let ffmpeg finalize
	// the webm container before exiting.
	process.kill(state.pid, "SIGTERM");

	for (let i = 0; i < 60; i++) {
		if (!isRunning(state.pid)) break;
		await new Promise((r) => setTimeout(r, 500));
	}

	unlinkSync(STATE_FILE);
	console.log(state.path);
}

async function runWorker(outputPath) {
	const b = await Promise.race([
		puppeteer.connect({
			browserURL: "http://localhost:9222",
			defaultViewport: null,
		}),
		new Promise((_, reject) => setTimeout(() => reject(new Error("timeout")), 5000)),
	]).catch((e) => {
		console.error("Could not connect to browser:", e.message);
		process.exit(1);
	});

	const page = (await b.pages()).at(-1);
	if (!page) {
		console.error("No active tab found");
		process.exit(1);
	}

	// screencast() waits for the first CDP frame, which never arrives if the
	// tab (or the OS-level Chrome window) isn't visible/focused.
	await page.bringToFront();

	let recorder;
	let stopping = false;
	const shutdown = async () => {
		if (stopping) return;
		stopping = true;
		if (recorder) await recorder.stop();
		await b.disconnect();
		process.exit(recorder ? 0 : 1);
	};
	process.on("SIGTERM", shutdown);
	process.on("SIGINT", shutdown);

	try {
		recorder = await Promise.race([
			page.screencast({ path: outputPath }),
			new Promise((_, reject) => setTimeout(() => reject(new Error("timed out waiting for the first frame — is the browser window visible?")), 10000)),
		]);
	} catch (e) {
		console.error("Failed to start screencast:", e.message);
		process.exit(1);
	}
}
