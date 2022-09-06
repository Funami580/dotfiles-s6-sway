local wezterm = require 'wezterm';

return {
  default_prog = {"/usr/bin/bash"},
  font = wezterm.font_with_fallback({
    "Hack",
    "Twemoji",
    "Noto Sans Symbols",
    "Noto Sans Symbols2",
  }),
  harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
  color_scheme = "F1r3w4tch",
  disable_default_key_bindings = true,
  key_map_preference = "Mapped",
  keys = {
    {key="c", mods="CTRL|SHIFT", action=wezterm.action{CopyTo="Clipboard"}},
    {key="v", mods="CTRL|SHIFT", action=wezterm.action{PasteFrom="Clipboard"}},
    {key="f", mods="CTRL|SHIFT", action=wezterm.action_callback(function(window, pane)
      local selection = window:get_selection_text_for_pane(pane)
      window:perform_action(wezterm.action{Search={CaseInSensitiveString=selection}}, pane)
    end)},
    {key="+", mods="CTRL", action="IncreaseFontSize"},
    {key="-", mods="CTRL", action="DecreaseFontSize"},
    {key="0", mods="CTRL", action="ResetFontSize"},
    {key="Numpad0", mods="CTRL", action="ResetFontSize"},
    {key="Home", mods="", action=wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action{SendKey={key="Home", mods=""}}, pane)
      else
        window:perform_action("ScrollToTop", pane)
      end
    end)},
    {key="End", mods="", action=wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action{SendKey={key="End", mods=""}}, pane)
      else
        window:perform_action("ScrollToBottom", pane)
      end
    end)},
    {key="PageUp", mods="", action=wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action{SendKey={key="PageUp", mods=""}}, pane)
      else
        window:perform_action(wezterm.action{ScrollByPage=-1}, pane)
      end
    end)},
    {key="PageDown", mods="", action=wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        window:perform_action(wezterm.action{SendKey={key="PageDown", mods=""}}, pane)
      else
        window:perform_action(wezterm.action{ScrollByPage=1}, pane)
      end
    end)},
    {key="Home", mods="CTRL", action=wezterm.action{SendKey={key="Home", mods=""}}},
    {key="End", mods="CTRL", action=wezterm.action{SendKey={key="End", mods=""}}},
    {key="PageUp", mods="CTRL", action=wezterm.action{SendKey={key="PageUp", mods=""}}},
    {key="PageDown", mods="CTRL", action=wezterm.action{SendKey={key="PageDown", mods=""}}},
    {key="F12", mods="", action=wezterm.action_callback(function(window, pane)
      local info = pane:get_foreground_process_info()
      local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", "echo $PPID"})
      if success and tonumber(stdout) ~= info.ppid then
        wezterm.background_child_process({"kill", "-9", info.pid})
      end
    end)},
    {key="Backspace", mods="CTRL", action={SendKey={key="w", mods="CTRL"}}},
    {key="Delete", mods="CTRL", action={SendKey={key="d", mods="ALT"}}},
    {key="u", mods="CTRL|SHIFT", action=wezterm.action{CharSelect={copy_on_select=true, copy_to="Clipboard"}}},
  },
  mouse_bindings = {
    {
      event={Down={streak=1, button={WheelUp=1}}},
      mods="CTRL",
      action="IncreaseFontSize",
    },
    {
      event={Down={streak=1, button={WheelDown=1}}},
      mods="CTRL",
      action="DecreaseFontSize",
    },
  },
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  selection_word_boundary = " \t\n{}[]()\"'`.,;:!?",
  quick_select_alphabet = "asdfqweryxcvjkluiopmghtzbn",
  quote_dropped_files = "Posix",
  canonicalize_pasted_newlines = "LineFeed",
  audible_bell = "Disabled",
  exit_behavior = "Close",
  window_close_confirmation = "NeverPrompt",
  clean_exit_codes = {130},
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = true,
  scrollback_lines = 10000,
  min_scroll_bar_height = "2cell",
  alternate_buffer_wheel_scroll_speed = 5,
  animation_fps = 1,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  detect_password_input = false,
  check_for_updates = false,
  enable_wayland = true,
}
