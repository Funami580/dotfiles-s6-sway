#
# ~/.bash_profile
#

if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec sway |& ts '%Y-%m-%d %H:%M:%.S ' |& tee -a ~/.sway.log
fi
