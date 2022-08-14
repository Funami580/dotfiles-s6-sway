#!/bin/sh

# Get pid of the focused window
focused_pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid')

if [[ -z $focused_pid ]]; then
  # Nothing focused, so exit
  exit
fi

# Finds sinks related to the pid
#
# First entry: whether the first sink is currently muted
# Other entries: sink ids
muted_and_sinks=( $(
  pactl list sink-inputs |
  awk -v pid=$focused_pid \
    'BEGIN { count = 0 }
     $1 == "Sink" && $2 == "Input" { sink = $3 }
     $1 == "Mute:" { muted = $2 }
     $1 == "application.process.id" && $3 == "\""pid"\"" { if (count == 0) { print muted; count++ } print sink }' |
  tr -d '#'
) )

if [[ ${#muted_and_sinks[@]} -lt 2 ]]; then
  # No sinks available, so exit
  exit
fi

# Toggle mute for all sinks that are related to that pid
for ((i = 1; i < ${#muted_and_sinks[@]}; ++i)); do
  pactl set-sink-input-mute ${muted_and_sinks[$i]} toggle &
done

# Change window title
if [[ ${muted_and_sinks[0]} = "no" ]]; then
  swaymsg "[pid=\"$focused_pid\"] title_format \" %title\""
else
  swaymsg "[pid=\"$focused_pid\"] title_format \"%title\""
fi
