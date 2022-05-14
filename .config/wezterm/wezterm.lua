local wezterm = require 'wezterm';

return {
  default_prog = {"/usr/bin/bash"},
  font = wezterm.font_with_fallback({
    "Hack",
    "Twemoji",
    "Noto Sans Symbols",
    "Noto Sans Symbols2",
  }),
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
    {key="PageUp", mods="", action=wezterm.action{ScrollByPage=-1}},
    {key="PageDown", mods="", action=wezterm.action{ScrollByPage=1}},
    {key="Home", mods="", action="ScrollToTop"},
    {key="End", mods="", action="ScrollToBottom"},
    {key="F12", mods="", action=wezterm.action_callback(function(window, pane)
      local info = pane:get_foreground_process_info()
      local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", "echo $PPID"})
      if success and tonumber(stdout) ~= info.ppid then
        wezterm.background_child_process({"kill", "-9", info.pid})
      end
    end)},
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
  animation_fps = 1,
  check_for_updates = false,
  enable_wayland = true,
}
