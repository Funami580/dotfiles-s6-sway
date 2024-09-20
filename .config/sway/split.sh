#!/bin/bash
sh=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true) | .window_rect | .width >= .height')
if [[ "$?" -eq 0 ]]; then
  if [[ "$sh" = true ]]; then
    swaymsg splith
  elif [[ "$sh" = "false" ]]; then
    swaymsg splitv
  fi
fi
