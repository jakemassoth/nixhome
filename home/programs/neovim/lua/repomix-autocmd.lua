-- Autocommand to regenerate repomix file on save if config exists

local repomix_group = vim.api.nvim_create_augroup("RepomixAutoGenerate", { clear = true })

-- Function to find the project root directory
-- Tries Git root first, then falls back to current working directory of the buffer's file
local function get_project_root(bufnr)
	-- Try Git root using the buffer's directory as the starting point
	local file_path = vim.api.nvim_buf_get_name(bufnr)
	if file_path == "" then
		return nil
	end -- No filename, can't determine path

	local file_dir = vim.fn.fnamemodify(file_path, ":h")
	if file_dir == "" or file_dir == "." then
		file_dir = vim.fn.getcwd() -- Use CWD if path is relative or empty
	end

	-- Command to find git root
	local git_root_cmd = { "git", "rev-parse", "--show-toplevel" }

	-- Run synchronously as it's usually very fast and needed for the check
	local job_id = vim.fn.jobstart(git_root_cmd, {
		cwd = file_dir, -- Start search from the file's directory
		stdout_buffered = true,
		stderr_buffered = true,
	})

	if job_id > 0 then
		local result = vim.fn.jobwait({ job_id }, -1) -- Wait indefinitely
		-- Check if command succeeded (exit code 0) and produced output
		if result[3] == 0 and result[1] and #result[1] > 0 then
			-- result[1] is a table of lines, get the first one and trim whitespace
			return vim.fn.trim(result[1][1])
		end
	end

	-- Fallback: If not in a git repo or git command failed, maybe check for other markers?
	-- For now, let's just return nil if git fails, to be safe.
	-- Alternatively, you could fall back to vim.fn.getcwd() but that might not be the actual project root.
	-- Depending on your workflow, you might add more root markers here (e.g., searching upwards for specific files)
	-- A simpler fallback (less accurate if Neovim CWD != project root):
	-- return vim.fn.getcwd()

	-- Stricter approach: only run if we confidently found a git root
	return nil
end

vim.api.nvim_create_autocmd("BufWritePost", {
	group = repomix_group,
	pattern = "*", -- Run for any file type
	callback = function(args)
		-- Ensure the buffer has a name and isn't scratch/special
		if args.buf == 0 or vim.fn.bufname(args.buf) == "" then
			return
		end
		-- Avoid triggering infinite loops if the repomix output file itself is saved
		if vim.fn.expand("%:t") == "repomix-output.xml" then -- Adjust filename if needed
			return
		end

		local project_root = get_project_root(args.buf)

		-- If we didn't find a root (e.g., not in a git repo), do nothing
		if not project_root then
			return
		end

		local config_file = project_root .. "/repomix.config.json"

		-- Check if the repomix config file exists and is readable
		if vim.fn.filereadable(config_file) == 1 then
			vim.notify("Repomix: Config found, regenerating...", vim.log.levels.INFO, { title = "Repomix" })

			-- Run repomix asynchronously in the project root
			vim.fn.jobstart({ "repomix" }, {
				cwd = project_root,
				-- Optional: Capture output/errors if needed for debugging
				-- stdout_buffered = true,
				-- stderr_buffered = true,
				on_exit = function(_, exit_code, event)
					if exit_code == 0 then
						vim.notify("Repomix: Generation complete.", vim.log.levels.INFO, { title = "Repomix" })
					else
						vim.notify(
							"Repomix: Generation failed (code: " .. exit_code .. ")",
							vim.log.levels.ERROR,
							{ title = "Repomix" }
						)
						-- You could print stderr here if captured:
						-- local stderr = vim.fn.jobgetstderr(job_id) -- requires capturing stderr above
						-- print("Repomix stderr:", table.concat(stderr, "\n"))
					end
				end,
			})
		end
	end,
})

print("Repomix autocommand loaded.") -- Confirmation message (optional)
