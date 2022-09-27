#!/bin/bash
if ! swaymsg -t get_outputs | jq -r --exit-status '.[] | select(.name=="HEADLESS-1" and .rect.height==768)' &> /dev/null; then
  swaymsg "output HEADLESS-1 mode 1366x768@60Hz"
else
  swaymsg "output HEADLESS-1 mode 1366x742@60Hz"
fi
