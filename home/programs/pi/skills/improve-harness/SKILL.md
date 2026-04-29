---
name: improve-harness
description: Reflect on a recently completed task to identify and fix friction points in the codebase harness. Use after a long or difficult session to improve AGENTS.md, tests, lints, build commands, scripts, and tooling so future agents run smoother.
---

# Improve Harness

This skill runs a retro on the current conversation to find and fix parts of the codebase that slow agents down. The goal is continuous improvement: each task should leave the repo slightly easier for the next agent.

## When to use

- After a task took multiple turns, backtracks, or tool failures.
- When you had to guess at conventions, commands, or file locations.
- When tests, lints, or builds failed in surprising ways.
- When AGENTS.md or README instructions were wrong or missing.

## Process

### 1. Reflect
Review the conversation history. For each bump you hit, note:
- What you were trying to do
- What you expected to happen
- What actually happened (error, silence, wrong result, missing file)
- How many turns it cost

### 2. Categorize friction
Map each bump to one or more categories:

| Category | Examples |
|---|---|
| **AGENTS.md / docs** | Outdated paths, wrong commands, missing conventions, stale examples, rules you had to discover by trial-and-error |
| **Tests** | Flaky tests, missing tests for the area you touched, tests that fail locally but pass in CI (or vice versa), slow tests, tests with hidden state |
| **Lint / Format** | Rules that fail without autofix, formatter version mismatches, lint rules that conflict with each other, ignored files that should be linted |
| **Build / Commands** | Undocumented build steps, slow rebuilds, commands that require manual env setup, nix/build scripts that fail on first run |
| **Scripts / Tooling** | Helper scripts with hardcoded paths, missing error handling, scripts that depend on tools not listed in deps |
| **Structure** | Files hard to find, modules too shallow or too deep, inconsistent naming, missing boundaries |

### 3. Prioritize
Pick 1–3 fixes with the highest ratio of **future agent time saved** to **effort now**. Prefer:
- Doc updates (fast, high impact)
- Adding or fixing a single test
- Adding one lint autofix rule
- Adding a script guard or error message

Avoid large refactors unless the friction is severe.

### 4. Implement
For each chosen fix:
- Make the smallest change that solves the problem.
- Update docs *first* if the fix changes a convention.
- Add or update tests to cover the new behavior.
- Run the relevant checks (`nix flake check`, test suite, linter, script) to verify.

### 5. Summarize
Report back with:
- The friction points you found
- What you changed
- What you decided *not* to change and why
- Any follow-ups that are too large for this retro

## Example output

```
Friction found:
1. AGENTS.md said tests are in `test/` but they are actually in `tests/`.
2. `nix flake check` fails on macOS because of a Linux-only input.
3. No test coverage for the error path I added.

Changes made:
- Fixed path in AGENTS.md
- Added a note about macOS skips to AGENTS.md Build section
- Added a unit test for the error path in `tests/core/test_foo.py`

Not changed:
- Full macOS compatibility fix (too large, file issue #123)
```

## Constraints

- Do not delete working conventions just because they confused you once. Clarify or add examples instead.
- Do not add heavy new tooling unless the problem is recurring.
- Always run the harness you changed before declaring done.
