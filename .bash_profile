#
# ~/.bash_profile
#

function start_sway() {
  # Mozilla: Enable Wayland and WebRender
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_WEBRENDER=1

  # https://github.com/swaywm/sway/wiki#i-cant-open-links-in-external-applications-in-firefox
  export MOZ_DBUS_REMOTE=1

  # https://github.com/swaywm/sway/wiki#disabling-client-side-qt-decorations
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

  # https://github.com/swaywm/sway/wiki#issues-with-java-applications
  export _JAVA_AWT_WM_NONREPARENTING=1

  # https://github.com/swaywm/sway/wiki#issues-with-jetbrains-ide-popupsmenus-losing-focus
  export STUDIO_JDK=/usr/lib/jvm/java-11-openjdk/

  # cliphist: remove old history
  rm -f ~/.cache/cliphist/db

  # Start sway
  export XDG_CURRENT_DESKTOP=sway
  mkdir -p ~/.var/log/sway
  dbus-run-session sway |& s6-log -b -- n3 s2000000 T ~/.var/log/sway

  # Reset environment
  unset MOZ_ENABLE_WAYLAND MOZ_WEBRENDER MOZ_DBUS_REMOTE \
        QT_QPA_PLATFORM QT_WAYLAND_DISABLE_WINDOWDECORATION \
        _JAVA_AWT_WM_NONREPARENTING STUDIO_JDK \
        XDG_CURRENT_DESKTOP
}

if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  start_sway
fi
