local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local function find_dirs(dir, mindepth, maxdepth)
	local cmd = string.format("find %s -mindepth %d -maxdepth %d -type d 2>/dev/null", dir, mindepth, maxdepth)
	local _, stdout, _ = wezterm.run_child_process({ os.getenv("SHELL"), "-c", cmd })
	local paths = {}
	for _, line in ipairs(wezterm.split_by_newlines(stdout)) do
		if line ~= "" then
			table.insert(paths, line)
		end
	end
	return paths
end

local function path_to_name(path)
	local name = path:match("([^/]+)$") or path
	return name:gsub("%.", "_")
end

local function get_sessionizer_choices()
	local choices = {}
	local existing = {}

	for _, ws in ipairs(mux.get_workspace_names()) do
		existing[ws] = true
		table.insert(choices, { id = "ws:" .. ws, label = "  " .. ws })
	end

	local home = wezterm.home_dir
	local all_dirs = {}
	for _, p in ipairs(find_dirs(home .. "/github.com", 2, 2)) do
		table.insert(all_dirs, p)
	end
	for _, p in ipairs(find_dirs(home .. "/github.com/verifybv/firebase-monorepo-worktrees", 1, 1)) do
		table.insert(all_dirs, p)
	end

	for _, path in ipairs(all_dirs) do
		local name = path_to_name(path)
		if not existing[name] then
			table.insert(choices, { id = "dir:" .. path, label = path:gsub(home, "~") })
		end
	end

	return choices
end

local switch_workspace = wezterm.action_callback(function(window, pane)
	local current_workspace = window:active_workspace()
	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
				if not id then
					return
				end
				wezterm.GLOBAL.previous_workspace = current_workspace
				if id:sub(1, 3) == "ws:" then
					inner_window:perform_action(act.SwitchToWorkspace({ name = id:sub(4) }), inner_pane)
				elseif id:sub(1, 4) == "dir:" then
					local path = id:sub(5)
					inner_window:perform_action(
						act.SwitchToWorkspace({ name = path_to_name(path), spawn = { cwd = path } }),
						inner_pane
					)
				end
			end),
			title = "Sessionizer",
			fuzzy_description = "Switch to: ",
			description = "Enter = open, Esc = cancel, / = filter",
			choices = get_sessionizer_choices(),
			fuzzy = true,
		}),
		pane
	)
end)

local switch_to_prev_workspace = wezterm.action_callback(function(window, pane)
	local current = window:active_workspace()
	local prev = wezterm.GLOBAL.previous_workspace
	if not prev or prev == current then
		return
	end
	wezterm.GLOBAL.previous_workspace = current
	window:perform_action(act.SwitchToWorkspace({ name = prev }), pane)
end)

local config = wezterm.config_builder()

config.window_decorations = "RESIZE"
config.front_end = "WebGpu"
config.default_prog = { fish_path, "-l" }
-- config.cell_width = 0.9
config.keys = {
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

	{ key = "S", mods = "CTRL|SHIFT", action = switch_workspace },
}

return config
