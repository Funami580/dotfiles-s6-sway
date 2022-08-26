#!/bin/sh

function clean_services() {
  if [[ -d /tmp/${USER}/s6-rc ]]; then
    s6-rc -l /tmp/${USER}/s6-rc -bDa change
  fi
  pkill -xU ${UID} s6-svscan
  rm -rf /tmp/${USER}/service
  find /tmp/${USER} -maxdepth 1 -type d -name s6-rc* -print0 | xargs -0 rm -r &> /dev/null || true
}

# Clean up old s6 user services, if any exist
clean_services

# Fix OBS not working
# https://github.com/emersion/xdg-desktop-portal-wlr/wiki/%22It-doesn't-work%22-Troubleshooting-Checklist
dbus-update-activation-environment DISPLAY I3SOCK SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Start new s6 user services
mkdir -p /tmp/${USER}/service
mkdir -p ~/.var/log/user-services
bash -c 's6-svscan /tmp/${USER}/service |& s6-log -b -- n3 s2000000 T ~/.var/log/user-services' &
sleep 0.1
s6-rc-init -c /home/${USER}/.local/share/s6/rc/compiled -l /tmp/${USER}/s6-rc /tmp/${USER}/service
s6-rc -l /tmp/${USER}/s6-rc -u change default

# Wait until sway exits, so we can stop the services
swaymsg -m -t subscribe '[]' # https://github.com/swaywm/sway/issues/7128
clean_services
