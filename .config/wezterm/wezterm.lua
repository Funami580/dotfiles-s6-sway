local wezterm = require 'wezterm';

return {
  default_prog = {"/usr/bin/bash"},
  font = wezterm.font_with_fallback({
    "Hack",
    "Twemoji",
  }),
  color_scheme = "F1r3w4tch",
  disable_default_key_bindings = true,
  keys = {
    {key="c", mods="CTRL|SHIFT", action=wezterm.action{CopyTo="Clipboard"}},
    {key="v", mods="CTRL|SHIFT", action=wezterm.action{PasteFrom="Clipboard"}},
    {key="+", mods="CTRL", action="IncreaseFontSize"},
    {key="-", mods="CTRL", action="DecreaseFontSize"},
    {key="0", mods="CTRL", action="ResetFontSize"},
    {key="Numpad0", mods="CTRL", action="ResetFontSize"},
    {key="PageUp", mods="", action=wezterm.action{ScrollByPage=-1}},
    {key="PageDown", mods="", action=wezterm.action{ScrollByPage=1}},
    {key="Home", mods="", action="ScrollToTop"},
    {key="End", mods="", action="ScrollToBottom"},
    {key="f", mods="CTRL|SHIFT", action=wezterm.action{Search={CaseInSensitiveString=""}}},
  },
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  selection_word_boundary = " \t\n{}[]()\"'`.,;:!?",
  audible_bell = "Disabled",
  exit_behavior = "Close",
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = true,
  scrollback_lines = 10000,
  check_for_updates = false,
}
