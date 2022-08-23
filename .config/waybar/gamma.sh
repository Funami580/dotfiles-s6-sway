#!/bin/sh
if [[ $# -ne 1 ]]; then
  echo "Illegal amount of arguments. Info: $1"
  exit 1
fi

BRIGHTNESS_MODE="/tmp/${UID}-waybar-gamma-mode-brightness"

if [[ "$1" = "current" ]]; then
  if [[ -d "${BRIGHTNESS_MODE}" ]]; then
    echo -e "\xef\x86\x85"
    # Long form:
    # echo -e "\xef\x86\x85 $(busctl --user -- introspect rs.wl-gammarelay / rs.wl.gammarelay | awk '$1 == ".Brightness" { print 100*$4 }')%"
  else
    echo -e "\xef\x86\x86"
    # Long form:
    # echo -e "\xef\x86\x86 $(busctl --user -- introspect rs.wl-gammarelay / rs.wl.gammarelay | awk '$1 == ".Temperature" { print $4 }')"
  fi
  exit 0
fi

LOCK="/tmp/${UID}-waybar-gamma"
if ! mkdir "${LOCK}"; then
  exit 0
fi
trap "rm -r '${LOCK}'" EXIT

if [[ "$1" = "default" ]]; then
  while ! busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4500; do
    sleep 0.1
  done
  while ! busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 0.8; do
    sleep 0.1
  done
  exit 0
fi

if [[ -d "${BRIGHTNESS_MODE}" ]]; then
  if [[ "$1" = "switch-mode" ]]; then
    rm -r "${BRIGHTNESS_MODE}"
    pkill -SIGRTMIN+8 -xnU ${UID} waybar
  elif [[ "$1" = "up" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d 0.05
  elif [[ "$1" = "down" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.05
  elif [[ "$1" = "toggle" ]]; then
    current_brightness=$(busctl --user -- introspect rs.wl-gammarelay / rs.wl.gammarelay | awk '$1 == ".Brightness" { print 100*$4 }')
    if [[ $current_brightness -eq 100 ]]; then
      busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 0.8
    else
      busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 1
    fi
  else
    echo "Illegal argument: $1"
    exit 1
  fi
else
  if [[ "$1" = "switch-mode" ]]; then
    mkdir "${BRIGHTNESS_MODE}"
    pkill -SIGRTMIN+8 -xnU ${UID} waybar
  elif [[ "$1" = "up" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n 100
  elif [[ "$1" = "down" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100
  elif [[ "$1" = "toggle" ]]; then
    current_temp=$(busctl --user -- introspect rs.wl-gammarelay / rs.wl.gammarelay | awk '$1 == ".Temperature" { print $4 }')
    if [[ $current_temp -eq 6500 ]]; then
      busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4500
    else
      busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500
    fi
  else
    echo "Illegal argument: $1"
    exit 1
  fi
fi
