#!/bin/sh
LOCK="/tmp/${UID}-night-mode"
if mkdir "${LOCK}"; then
  bash -c '[[ -n $(pidof gammastep) ]] && killall -9 gammastep || gammastep -O 4500 &'
  kill -SIGRTMIN+8 "$(pidof waybar)"
  rm -r "${LOCK}"
fi
