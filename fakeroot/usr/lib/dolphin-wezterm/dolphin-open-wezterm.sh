#!/usr/bin/bash
wezterm start --always-new-process --cwd "$(pwd)" -- "$@"
