#!/bin/bash
swaymsg -t get_tree | jq  -r  '.nodes[].nodes[]  |  if  .nodes  then  [recurse(.nodes[])] else [] end + .floating_nodes | .[] | select(.nodes==[] and (.type=="con" or .type=="floating_con")) | ((.id | tostring) + ". " + .name)' | wofi -i -p '' -M multi-contains -d | {
    read -r index name
    id=$(echo -n "${index}" | sed 's/\.//')
    swaymsg "[con_id=$id]" focus
}
