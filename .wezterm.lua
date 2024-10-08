-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- Add full screen key binding
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

-- Font
config.font = wezterm.font("Iosevka Term")

-- window padding
config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- bg opacity
config.window_background_opacity = 0.92

-- theme
config.color_scheme = "rose-pine"

-- Spawn a pwsh shell in login mode
config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-l", "-nologo" }

-- and finally, return the configuration to wezterm
return config
