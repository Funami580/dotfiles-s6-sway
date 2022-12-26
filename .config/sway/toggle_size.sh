#!/bin/bash
if ! swaymsg -t get_outputs | jq -r --exit-status '.[] | select(.name=="HEADLESS-1" and .rect.height==900)' &> /dev/null; then
  swaymsg "output HEADLESS-1 mode 1600x900@60Hz"
else
  swaymsg "output HEADLESS-1 mode 1600x876@60Hz"
fi
