#!/bin/bash
# workaround for https://github.com/swaywm/sway/issues/5931
mapfile -t args < <( printf "%q\n" "$@" )
swaymsg exec -- "${args[@]}"
