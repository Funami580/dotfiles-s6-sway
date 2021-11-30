#!/bin/sh
focused_pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid')

if [[ -z $focused_pid ]]; then
    exit
fi

sink=$(pactl list sink-inputs | awk -v pid=$focused_pid '$1 == "Sink" && $2 == "Input" {idx = $3} $1 == "application.process.id" && $3 == "\""pid"\"" {print idx; exit}' | tr -d '#')

if [[ -z $sink ]]; then
    exit
fi

pactl set-sink-input-mute $sink toggle

exit
# Future: TODO
is_muted=$(pactl list sink-inputs | awk -v pid=$focused_pid '$1 == "Mute:" {idx = $2} $1 == "application.process.id" && $3 == "\""pid"\"" {print idx; exit}')

if [[ $is_muted = "no" ]]; then
    swaymsg for_window "[pid=$focused_pid]" 'title_format "%title"'
else
    swaymsg for_window "[pid=$focused_pid]" 'title_format " %title"'
fi

while test -d /proc/$focused_pid; do
    sleep 1
done

swaymsg for_window "[pid=$focused_pid]" 'title_format "%title"'
