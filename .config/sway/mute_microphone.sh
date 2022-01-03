#!/bin/sh
while true; do
  pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes
  if [[ $? = 0 ]]; then
    break
  fi
  pactl set-source-mute @DEFAULT_SOURCE@ 1
  pactl set-source-volume @DEFAULT_SOURCE@ 50%
  sleep 0.1
done
