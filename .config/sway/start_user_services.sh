#!/bin/sh
# Clean up old s6 user services
s6-rc -l /tmp/${USER}/s6-rc -bDa change
rm -rf /tmp/${USER}/service
find /tmp/${USER} -maxdepth 1 -type d -name s6-rc* -print0 | xargs -0 rm -r &> /dev/null || true

# Start new s6 user services
mkdir -p /tmp/${USER}/service
mkdir -p ~/.var/log/user-services
bash -c 's6-svscan /tmp/${USER}/service |& s6-log -b -- n3 s2000000 T ~/.var/log/user-services' &
sleep 0.1
s6-rc-init -c /home/${USER}/.local/share/s6/rc/compiled -l /tmp/${USER}/s6-rc /tmp/${USER}/service
s6-rc -l /tmp/${USER}/s6-rc -u change default