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
    {key="Home", mods="", action=wezterm.action{ScrollByLine=-15000}},
    {key="End", mods="", action=wezterm.action{ScrollByLine=15000}},
    {key="f", mods="CTRL|SHIFT", action=wezterm.action{Search={CaseInSensitiveString=""}}},
  },
  selection_word_boundary = " \t\n{}[]()\"'`.,;:",
  exit_behavior = "Close",
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = true,
  scrollback_lines = 10000,
  check_for_updates = false,
  enable_wayland = true,
}
