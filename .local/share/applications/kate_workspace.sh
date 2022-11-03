#!/usr/bin/env bash
if [[ "$#" -eq 0 ]]; then
  exec swaymsg 'exec kate --new'
fi

active_workspace=$(swaymsg -t get_workspaces | jq '.[] | select(.focused).id')
kate_pid=$(swaymsg -t get_tree | jq -e '.nodes[].nodes[] | select(.type == "workspace" and .id == '"${active_workspace}"').nodes[] | select(.app_id == "org.kde.kate").pid')

if [[ "$?" -eq 0 ]]; then
  exec kate --block --pid "${kate_pid}" -- "$@"
else
  exec swaymsg 'exec kate --new -- '"$(printf '%q ' "$@")"
fi
