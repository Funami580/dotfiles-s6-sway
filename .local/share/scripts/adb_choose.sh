#!/bin/bash
mapfile -t DEVICES < <(adb devices -l | grep -v -e 'List of devices attached' -e '^$')

if [[ "${#DEVICES[@]}" -eq 0 ]]; then
  exit 1
fi

mapfile -t IDS  < <(printf "%s\n" "${DEVICES[@]}" | awk '{ print $1 }')

if [[ "${#IDS[@]}" -eq 1 ]]; then
  echo "${IDS[0]}"
  exit 0
fi

mapfile -t MODELS < <(printf "%s\n" "${DEVICES[@]}" | sed -E 's/.*model:([^ ]*).*/\1/' | sed 's/_/ /g')
mapfile -t DEVID < <(printf "%s\n" "${DEVICES[@]}" | sed -E 's/.*device:([^ ]*).*/\1/')

unset NAMES
for (( i=0; i<${#MODELS[@]}; ++i)); do
  curr_name=$(printf "${MODELS[$i]} (${DEVID[$i]})" | sed -E 's/ {2,}/ /'g)
  NAMES+=( "${curr_name}" )
done

index=$(wofi -i -p '' -d -c <(echo dmenu-print_line_num=true) < <(printf "%s\n" "${NAMES[@]}"))

if [[ "$?" -ne 0 ]]; then
  exit 1
fi

echo "${IDS[$index]}"
