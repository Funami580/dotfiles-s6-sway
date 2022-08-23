#!/usr/bin/bash
#
# Change the default terminal emulator for Dolphin to WezTerm by adding this to the ~/.config/kdeglobals file:
#
# [General]
# TerminalApplication=~/.config/wezterm/dolphin-open-wezterm.sh
#
exec wezterm start --always-new-process --cwd "${PWD}" -- "$@"
