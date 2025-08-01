local b = require("utils.background")
local h = require("utils.helpers")
local wezterm = require("wezterm")
local assets = wezterm.config_dir .. "/assets"
local config = wezterm.config_builder()

-- set this to true to enable fancy background
local fancy = false

config.macos_window_background_blur = 30
config.enable_tab_bar = false
config.window_decorations = "TITLE | RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.initial_rows = 29
config.initial_cols = 120
config.native_macos_fullscreen_mode = false
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

local act = wezterm.action
config.keys = {
	{ mods = "OPT", key = "LeftArrow", action = act.SendKey({ mods = "ALT", key = "b" }) },
	{ mods = "OPT", key = "RightArrow", action = act.SendKey({ mods = "ALT", key = "f" }) },
	{ mods = "CMD", key = "LeftArrow", action = act.SendKey({ mods = "CTRL", key = "a" }) },
	{ mods = "CMD", key = "RightArrow", action = act.SendKey({ mods = "CTRL", key = "e" }) },
	{ mods = "CMD", key = "Backspace", action = act.SendKey({ mods = "CTRL", key = "u" }) },
	{ mods = "CMD|OPT", key = "LeftArrow", action = act.ActivateTabRelative(-1) },
	{ mods = "CMD|OPT", key = "RightArrow", action = act.ActivateTabRelative(1) },
	{ mods = "CMD|SHIFT", key = "LeftArrow", action = act.ActivateTabRelative(-1) },
	{ mods = "CMD|SHIFT", key = "RightArrow", action = act.ActivateTabRelative(1) },
	{ mods = "SHIFT", key = "Enter", action = act.Multiple { act.SendString "\\", act.SendKey { key = "Enter" }, }, },
}

config.harfbuzz_features = { "calt", "dlig", "clig=1", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
config.font_size = 16
config.line_height = 1.1
config.adjust_window_size_when_changing_font_size = false

-- keys config
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

if h.is_dark then
  -- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Macchiato"]
  -- -- set a custom, darker background color for Macchiato
  -- custom.background = "#0b0b12"

  -- override the Catppuccin Macchiato color scheme
  -- config.color_schemes = {
  --   ["Catppuccin Macchiato"] = custom,
  -- }

  -- and use the custom color scheme
  -- config.color_scheme = "Catppuccin Macchiato"
  config.color_scheme = "Catppuccin Macchiato"
  config.set_environment_variables = {
    THEME_FLAVOUR = "macchiato",
  }
  if fancy then
    config.background = {
      b.get_background(),
      b.get_animation(assets .. "/blob_blue.gif"),
    }
  end
else
  config.color_scheme = "Catppuccin Latte"
  config.window_background_opacity = 1
  config.set_environment_variables = {
    THEME_FLAVOUR = "latte",
  }
  config.background = {
    b.get_background(),
  }
end

config.default_cursor_style = 'BlinkingUnderline'
config.colors = {
  cursor_border = "#00FF00",
  cursor_bg = "#00FF00",
}

config.animation_fps = 1
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

return config
