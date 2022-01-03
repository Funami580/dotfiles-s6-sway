#!/bin/sh
mem_percent=$(LC_MESSAGES=C free -m | awk '$1 == "Mem:" { print 100*($2-$7)/$2 }' | LC_NUMERIC=C xargs printf "%.0f" | xargs printf "%2s")
swap_percent=$(LC_MESSAGES=C free -m | awk '$1 == "Swap:" { print 100*$3/$2 }' | LC_NUMERIC=C xargs printf "%.0f" | xargs printf "%2s")
mem_used=$(LC_MESSAGES=C free -m | awk '$1 == "Mem:" { print ($2-$7)/1024 }' | LC_NUMERIC=C xargs printf "%.1f")
mem_total=$(LC_MESSAGES=C free -m | awk '$1 == "Mem:" { print $2/1024 }' | LC_NUMERIC=C xargs printf "%.1f")
swap_used=$(LC_MESSAGES=C free -m | awk '$1 == "Swap:" { print $3/1024 }' | LC_NUMERIC=C xargs printf "%.1f")
swap_total=$(LC_MESSAGES=C free -m | awk '$1 == "Swap:" { print $2/1024 }' | LC_NUMERIC=C xargs printf "%.1f")
echo '{"text": "'"${mem_percent}"'", "tooltip": "Mem: '"$(echo -e "${mem_percent}% ${mem_used}GiB/${mem_total}GiB\n${swap_percent}% ${swap_used}GiB/${swap_total}GiB" | column -t -R 1,2 | sed '2s/^/Swp: /' | head -c -1 | tr '\n' '*' | sed 's/*/\\n/g')"'" }'
