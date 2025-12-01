local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("IosevkaTerm Nerd Font", { weight = "Medium", stretch = "Normal", style = "Normal" })
config.font_size = 18

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "tokyonight_night"
	else
		return "tokyonight_day"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.inactive_pane_hsb = { saturation = 0.24, brightness = 0.5 }

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

return config
