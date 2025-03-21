local wezterm = require("wezterm")
local mux = wezterm.mux

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

config.keys = {
	{
		key = "f",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "h",
		mods = "SHIFT|CTRL|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "SHIFT|CTRL|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "r",
		mods = "SHIFT|CTRL|ALT",
		action = wezterm.action.ReloadConfiguration,
	},
}

config.font = wezterm.font("IosevkaTerm NFM")

config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.window_background_opacity = 0.96

config.term = "xterm-256color"
-- config.color_scheme = "rose-pine"

config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-l", "-nologo" }

return config
