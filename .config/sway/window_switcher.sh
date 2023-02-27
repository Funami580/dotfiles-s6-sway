#!/bin/bash
swaymsg -t get_tree | jq  -r  '.nodes[].nodes[]  |  if  .nodes  then  [recurse(.nodes[])] else [] end + .floating_nodes | .[] | select(.nodes==[] and (.type=="con" or .type=="floating_con")) | ((.id | tostring) + " " +
.name)' | wofi -i -p '' -M multi-contains -r $'cat <<EOF | cut -f 1 -d " " --complement | head -c -1\n%s\nEOF\n' -d | {
    read -r id name
    swaymsg "[con_id=$id]" focus
}
