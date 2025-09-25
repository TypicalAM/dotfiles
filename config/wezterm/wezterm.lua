---@type Wezterm
local wezterm = require 'wezterm'
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm')

---@type Config
local config = wezterm.config_builder()

---@type Action
local act = wezterm.action

wezterm.on('update-right-status', function(window, _)
	window:set_right_status(window:active_workspace())
end)

wezterm.on('user-var-changed', function(window, pane, name, value)
	if name == 'switch-workspace' then
		local cmd_context = wezterm.json_parse(value)
		window:perform_action(
			act.SwitchToWorkspace {
				name = cmd_context.workspace,
				spawn = {
					cwd = cmd_context.cwd,
				},
			},
			pane
		)
	end
end)

config.colors = theme.main.colors()
config.window_frame = theme.main.window_frame()

config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMonoNL Nerd Font", weight = "Regular", italic = false },
})
config.initial_cols = 80 -- kitty width 700px / font ~8.75px ≈ 80 cols
config.initial_rows = 24 -- kitty height 400px / font ~16px ≈ 24 rows
config.adjust_window_size_when_changing_font_size = false
config.font_size = 16.0
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}
config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}
config.window_background_opacity = 1.0
config.text_background_opacity = 1.0

-- Tabs
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Keybindings
config.keys = {
	-- Clipboard
	{ key = "V",          mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "C",          mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },

	-- Font size
	{ key = "=",          mods = "CTRL|SHIFT", action = "IncreaseFontSize" },
	{ key = "-",          mods = "CTRL|SHIFT", action = "DecreaseFontSize" },
	{ key = "Backspace",  mods = "CTRL|SHIFT", action = "ResetFontSize" },

	-- Config reload
	{ key = "R",          mods = "CTRL|ALT",   action = wezterm.action.ReloadConfiguration },

	-- Ctrl+Enter → send ESC (\u001b)
	{ key = "Enter",      mods = "CTRL",       action = wezterm.action.SendString("\u{1b}") },

	-- Shift+Enter → send \u001d
	{ key = "Enter",      mods = "SHIFT",      action = wezterm.action.SendString("\u{1d}") },

	-- Alt+Left/Right: previous/next tab
	{ key = "LeftArrow",  mods = "ALT",        action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "ALT",        action = wezterm.action.ActivateTabRelative(1) },

	-- Alt+1..6: switch to tab index 0..5
	{ key = "1",          mods = "ALT",        action = wezterm.action.ActivateTab(0) },
	{ key = "2",          mods = "ALT",        action = wezterm.action.ActivateTab(1) },
	{ key = "3",          mods = "ALT",        action = wezterm.action.ActivateTab(2) },
	{ key = "4",          mods = "ALT",        action = wezterm.action.ActivateTab(3) },
	{ key = "5",          mods = "ALT",        action = wezterm.action.ActivateTab(4) },
	{ key = "6",          mods = "ALT",        action = wezterm.action.ActivateTab(5) },

	-- Ctrl+T: open new tab
	{ key = "t",          mods = "CTRL",       action = wezterm.action.SpawnTab("DefaultDomain") },
	{
		key = "s",
		mods = "CTRL",
		action = wezterm.action.ShowLauncherArgs {
			flags = 'FUZZY|WORKSPACES',
		}
	},
	{
		key = "n",
		mods = "CTRL",
		action = wezterm.action.PromptInputLine {
			description = wezterm.format {
				{ Attribute = { Intensity = 'Bold' } },
				{ Foreground = { AnsiColor = 'Red' } },
				{ Text = 'Enter name for new workspace' },
			},
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line and line ~= "" then
					window:perform_action(
						wezterm.action.SwitchToWorkspace {
							name = line,
						},
						pane
					)
				end
			end),
		}
	},
	{
		key = "r",
		mods = "CTRL",
		action = wezterm.action.PromptInputLine {
			description = 'Enter new name for workspace',
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line and line ~= "" then
					wezterm.mux.rename_workspace(window:active_workspace(), line)
				end
			end),
		},
	},
	{
		key = 'y',
		mods = 'CTRL',
		action = wezterm.action_callback(function(window, pane)
			-- Here you can dynamically construct a longer list if needed

			local home = wezterm.home_dir
			local workspaces = {
				{ id = home,                label = 'Home' },
				{ id = home .. '/work',     label = 'Work' },
				{ id = home .. '/personal', label = 'Personal' },
				{ id = home .. '/.config',  label = 'Config' },
			}

			window:perform_action(
				wezterm.action.InputSelector {
					action = wezterm.action_callback(
						function(inner_window, inner_pane, id, label)
							if not id and not label then
								wezterm.log_info 'cancelled'
							else
								wezterm.log_info('id = ' .. id)
								wezterm.log_info('label = ' .. label)
								inner_window:perform_action(
									wezterm.action.SwitchToWorkspace {
										name = label,
										spawn = {
											label = 'Workspace: ' .. label,
											cwd = id,
										},
									},
									inner_pane
								)
							end
						end
					),
					title = 'Choose Workspace',
					choices = workspaces,
					fuzzy = true,
					fuzzy_description = 'Fuzzy find and/or make a workspace',
				},
				pane
			)
		end),
	},

	-- Ctrl+W: close current tab
	-- { key = "w",          mods = "CTRL",       action = wezterm.action.CloseCurrentTab({ confirm = false }) },
}

return config
