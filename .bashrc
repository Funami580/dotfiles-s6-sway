#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

temp_file=$(mktemp)
trap "rm $temp_file" EXIT

ps1_color() {
    if [[ $? = 0 ]]; then
        status_color='\033[32m'
    else
        status_color='\033[31m'
    fi
    
    read -r last_hist < $temp_file
    
    if [[ -z $last_hist ]]; then
        status_color=''
    fi
    
    if [[ $last_hist -ge $1 ]]; then
        status_color=''
    fi
    
    echo $1 > $temp_file
    echo -e "$status_color"
}

get_title() {
    history | awk '$1 == '"$1"' { print $0 }' | sed 's/\s*[0-9]*\s*//'
}

PS0='\[\e]2;$(get_title \!)\a\]'
if [[ ! -v DISABLE_HOST ]]; then
    PS1='\[\e]2;\u@\h:\w\a\][\u@\h \W]\[$(ps1_color \#)\]\$\[\033[0m\] '
else
    PS1='\[\e]2;\u@\h:\w\a\]\[$(ps1_color \#)\]\$\[\033[0m\] '
fi
HISTSIZE=5000
HISTFILESIZE=-1
HISTCONTROL=ignoreboth
HISTIGNORE='nohist:nohost:DISABLE_HIST=1 bash:DISABLE_HOST=1 bash'

shopt -q -s histappend
shopt -q -s nocaseglob

unset LC_ALL
export LANG=en_US.UTF-8
export LC_MESSAGES=C
export LC_PAPER=de_DE.UTF-8

export PATH="$PATH:~/.local/bin/:~/.cargo/bin/"
export BAT_PAGER="less -RiFx4 --mouse --wheel-lines=4"
export EXA_COLORS="reset:ex=31" # only color directories and executables

alias cdi='cd "$(fd -t d | fzf)"'
alias cdia='cd "$(fd -H -t d | fzf)"'
alias lsx='exa -lbh --group-directories-first'
alias loc='tokei' # lines of code
alias catr='cat -v' # cat-raw
alias hexv='hexv -f Hack,Twemoji'
alias russ='russ --database-path ~/.russ.db'

alias gu='git-user'
alias gua='git-user add'
alias guc='git-user current'

alias mimetype='file -b --mime-type'
alias mimetypec='file -bi' # mimetype with charset
alias fpermso='stat -c %a' # file permissions octal
alias fpermsh='stat -c %A' # file permissions human
alias fchown='stat -c %U:%G' # user:group information

no_home() {
    local args="$@"
    unshare -cm --keep-caps bash -c "mount -t tmpfs none /tmp; cp .Xauthority /tmp; mount -t tmpfs none /home/; mount -t tmpfs none /run/media/; cd /home; mkdir -p $USER; cd /home/$USER; mv /tmp/.Xauthority .Xauthority; $args"
}

alias nohist='DISABLE_HIST=1 bash'
alias nohost='clear && DISABLE_HOST=1 bash'
alias no-net='unshare -cn --keep-caps'
alias no-home='no_home'
alias mp3wrap2='find . -maxdepth 1 -iname "*.mp3" -print0 | sort -z | xargs -0 mp3wrap output.mp3 && mp3val -f output_MP3WRAP.mp3 && rm output_MP3WRAP.mp3.bak'
alias mpe-key='python -c "$(echo ZnJvbSBoYXNobGliIGltcG9ydCBzaGExCmltcG9ydCByYW5kb20sIHN0cmluZwoKCmRlZiBnZW5lcmF0ZV9yYW5kb21fYWxwaGFudW1fc3RyKGxlbmd0aDogaW50KSAtPiBzdHI6CiAgICBzID0gIiIKICAgIGZvciBfIGluIHJhbmdlKGxlbmd0aCk6CiAgICAgICAgcyArPSByYW5kb20uU3lzdGVtUmFuZG9tKCkuY2hvaWNlKHN0cmluZy5hc2NpaV91cHBlcmNhc2UgKwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzdHJpbmcuZGlnaXRzKQogICAgcmV0dXJuIHMKCgpkZWYgZG91YmxlX2hhc2goY29kZTogc3RyKSAtPiBzdHI6CiAgICBoYXNoID0gc2hhMShjb2RlLmVuY29kZSgiVVRGLTgiKSkuaGV4ZGlnZXN0KCkKICAgIGhhc2ggPSBzaGExKGhhc2guZW5jb2RlKCJVVEYtOCIpKS5oZXhkaWdlc3QoKQogICAgcmV0dXJuIGhhc2gKCgpkZWYga2V5Z2VuKHJlZ2lzdHJhdGlvbl9jb2RlOiBzdHIsIGNvbXB1dGVyX2lkOiBzdHIpIC0+IHN0cjoKICAgIHJlZ2lzdHJhdGlvbl9oYXNoID0gZG91YmxlX2hhc2gocmVnaXN0cmF0aW9uX2NvZGUpCiAgICBjb21wdXRlcl9oYXNoID0gZG91YmxlX2hhc2goY29tcHV0ZXJfaWRbOi00XSkKICAgIGNvbWJpbmVkX2hhc2ggPSAiIgogICAgZm9yIGkgaW4gcmFuZ2UobGVuKHJlZ2lzdHJhdGlvbl9oYXNoKSk6CiAgICAgICAgY29tYmluZWRfaGFzaCArPSByZWdpc3RyYXRpb25faGFzaFtpXSArIGNvbXB1dGVyX2hhc2hbaV0KICAgIGNvbWJpbmVkX2hhc2ggPSBzaGExKGNvbWJpbmVkX2hhc2guZW5jb2RlKCJVVEYtOCIpKS5oZXhkaWdlc3QoKQogICAgcmV0dXJuIGNvbWJpbmVkX2hhc2gudXBwZXIoKSArIGdlbmVyYXRlX3JhbmRvbV9hbHBoYW51bV9zdHIoMTApCgoKZGVmIG1haW4oKToKICAgIHMgPSAiTWFzdGVyIFBERiBFZGl0b3IgNS54IEtleWdlbiBbYnkgbjBrMG0zLCBvcmlnaW5hbGx5IGJ5IFJhZGlYWDExXSIKICAgIHByaW50KHMpCiAgICBwcmludCgiPSIgKiBsZW4ocykpCiAgICBwcmludCgpCiAgICBmb3JtYXRfc3R5bGUgPSAiezo8MjB9OiAiCiAgICBjb21wdXRlcl9pZCA9IGlucHV0KGZvcm1hdF9zdHlsZS5mb3JtYXQoIkNvbXB1dGVyIElEIikpCiAgICBpZiBsZW4oY29tcHV0ZXJfaWQpICE9IDQwOgogICAgICAgIHByaW50KAogICAgICAgICAgICAiW0VSUk9SXSBDb21wdXRlciBJRCBtdXN0IGJlIGEgNDAgY2hhcmFjdGVyIHN0cmluZywgaW5jbHVkaW5nIFwiLVwiIgogICAgICAgICkKICAgICAgICByZXR1cm4KICAgIHJlZ2lzdHJhdGlvbl9jb2RlID0gZ2VuZXJhdGVfcmFuZG9tX2FscGhhbnVtX3N0cigxOCkKICAgICMgcmVnaXN0cmF0aW9uX2NvZGUgPSAiVlZNWDVQSEZGUzZUNk1BTTc2IgogICAgYWN0aXZhdGlvbl9jb2RlID0ga2V5Z2VuKHJlZ2lzdHJhdGlvbl9jb2RlLCBjb21wdXRlcl9pZCkKICAgIHByaW50KGZvcm1hdF9zdHlsZS5mb3JtYXQoIlJlZ2lzdHJhdGlvbiBDb2RlIikgKyByZWdpc3RyYXRpb25fY29kZSkKICAgIHByaW50KGZvcm1hdF9zdHlsZS5mb3JtYXQoIkFjdGl2YXRpb24gQ29kZSIpICsgYWN0aXZhdGlvbl9jb2RlKQogICAgcHJpbnQoKQoKCmlmIF9fbmFtZV9fID09ICJfX21haW5fXyI6CiAgICBtYWluKCkK | base64 -d)"'

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#List_of_installed_packages
alias pacsize='LC_ALL=C pacman -Qi | awk "/^Installed Size/{print \$4\$5}" | sed -e s/KiB/*1024/ -e s/MiB/*$((1024*1024))/ -e s/GiB/*$((1024*1024*1024))/ | tr "\n" "+" | head -c -1 | sed -e s/^/scale=1\;\(/ -e s/$/\)\\/\(1024*1024*1024\)\\n/ | bc | sed "s/$/ GiB/"'
alias pacsizes='LC_ALL=C pacman -Qi | awk "/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}" | sort -hr'
alias pacrmorphans='sudo pacman -Rns $(pacman -Qdtq)'
alias pacrmcache='du -sh /var/cache/pacman/pkg/ && paccache -d | tail -n -1 && read -p "Continue to remove cached packages?" && sudo paccache -r | tail -n -1'
alias allinstalled='pacman -Qqe'
alias aurinstalled='pacman -Qqem'
alias pacinstalled='comm -23 <(allinstalled | sort) <(aurinstalled | sort)'
alias chaoticinstalled='paclist chaotic-aur | awk "{ print \$1 }" | xargs -I% bash -c "pacman -Qqe % > /dev/null; [[ \$? = 0 ]] && echo % || true"'
alias checkrebuildc='checkrebuild -i chaotic-aur'

aurpkg() {
    git clone "ssh://aur@aur.archlinux.org/$1.git"
    bash -c "cd \"$(pwd)/$1\" && git branch -m master"
}
alias srcinfo='makepkg --printsrcinfo > .SRCINFO'
inbasedevel() {
    LC_ALL=C pacman -Si $(pactree -rl "$1") 2>/dev/null | grep -q "^Groups *:.*base-devel"
    [[ $? = 0 ]] && echo "$1 is in base-devel" || echo "$1 is NOT in base-devel"
}
alias checkaurupd='python3 ~/Programme/AUR_packages/check_crates_updates.py'
bindeps() { objdump -p "$1" | awk '/NEEDED/ { print $2 }' | xargs whereis | awk '{ print $2 }' | xargs pacman -Qqo | sort | uniq; }
bindeps2() { objdump -p "$1" | awk '/NEEDED/ { print $2 }' | xargs whereis | xargs -I% bash -c 'echo $(echo % | cut -d: -f1): $(echo % | cut -d: -f2 | xargs pacman -Qqo)'; }
bindeps3() { ldd "$1" | grep "=> /" | cut -d ">" -f2 | cut -d "(" -f 1 | xargs pacman -Qqo | sort | uniq; }

alias neofetch='fastfetch --load-config ~/.config/fastfetch/presets/neofetch  | sed '"'"'s/Intel Xeon.*/Intel HD Graphics/'"'"''
alias cpu='echo -e "$(cat /proc/cpuinfo | grep "model name" | uniq | sed "s/.*model name[[:space:]:]*//")\n$(cat /proc/cpuinfo | grep -i "cpu cores" | uniq | sed "s/.*cpu cores[[:space:]:]*"//) Cores, $(cat /proc/cpuinfo | grep siblings | uniq | sed s/.*siblings[[:space:]:]*//) Threads\n$(lscpu | awk "/CPU max MHz/ {print \$4}" | cut -f 1 -d ".") MHz"'
alias mainboard='cat /sys/devices/virtual/dmi/id/board_{vendor,name,version}' # ; sudo dmesg | grep DMI: | sed "s/.*DMI[[:space:]:]*//"
alias memory='echo $(perl -E "printf(\"%.1f\", $(cat /proc/meminfo | grep MemTotal | sed s/[^[:digit:]]//g)*1000/1024/1024/1024)") GiB Memory'
alias gpu='lspci | grep -E "(VGA|3D)" | cut -d[ -f2 | cut -d] -f1' # only nvidia support, i guess
alias system='echo -e "CPU\n$(cpu | sed "s/^/> /")\n\nMemory\n$(memory | sed "s/^/> /")\n\nGPU\n$(gpu | sed "s/^/> /")\n\nMainboard\n$(mainboard | sed "s/^/> /")"'
alias ipl='ip a | awk "/inet .+\..+\..+\..+/ {print \$2}" | tail -n -1 | cut -d "/" -f 1'
alias ipr='echo -e "$(timeout 1 curl -s -4 ifconfig.co || echo No IPv4 found)\n$(timeout 1 curl -s -6 ifconfig.co || echo No IPv6 found)"'

# From: https://github.com/EaterOA/dotfiles/blob/master/.bashrc
# copy from stdin or file into X clipboard
alias copy='wl-copy'
# url encode/decode
alias urlencode='python3 -c "import sys, urllib.parse as u; sys.stdout.write(u.quote(sys.stdin.read(), \"/\n\"))"'
alias urldecode='python3 -c "import sys, urllib.parse as u; sys.stdout.write(u.unquote(sys.stdin.read()))"'
# html encode/decode
alias htmlencode='python3 -c "import sys, html as h; sys.stdout.write(h.escape(sys.stdin.read()))"'
alias htmldecode='python3 -c "import sys, html as h; sys.stdout.write(h.unescape(sys.stdin.read()))"'

alias screenoff='swaymsg "output VGA-1 power off"'

# Upload file to 0x0.st and copy url to clipboard
0x0() {
    local url=$(curl -s -F "file=@$1" "https://0x0.st" | tr -d "\n")
    echo -n "$url" | wl-copy
    echo "$url"
}

chr() {
    [ "$1" -lt 256 ] || return 1
    printf "\\$(printf '%03o' "$1")\n"
}

ord() {
    LC_CTYPE=C printf '%d\n' "'$1"
}

stfu() {
    ("$@" &> /dev/null &)
}

run_java() {
    local cur_dir=$(pwd)
    local tmp_dir=$(mktemp -d)
    cp *.java "$tmp_dir"
    cd "$tmp_dir"
    javac -encoding utf8 -cp . "$1"
    java "$(echo -n $1 | sed 's/.java//')"
    cd "$cur_dir"
    rm -rf "$tmp_dir"
}

cargo_unique_deps() {
    cargo tree --charset ascii | tail -n +2 | tr -d '|`-' | sed 's/^[ \t]*//g' | sed '/^\[.*/d' | awk '{ print $1 }' | sort | uniq
}

scan() {
    local i=0
    while read -n1 -s; do
        if [[ "$REPLY" == "q" ]]; then
            break
        fi
        if [[ $i -ne 0 ]]; then
            echo
        fi
        echo "Scanning picture $(($i + 1))..."
        scanimage --resolution=300 --format=png --output-file "$i.png" --progress
        let i++
    done
    if [[ $i -ne 0 ]]; then
        echo
        echo "Post-processing:"
        echo "[1/2] Converting to jpg..."
        for f in *.png; do
            convert "$f" -rotate 180 "$f"
            convert -quality 70 "$f" "${f%.png}.jpg"
        done
        echo "[2/2] Converting to pdf..."
        convert *.jpg output.pdf
        echo "Done!"
    fi
}

md2pdf() {
    local base_name=$(rev <<< "$1" | cut -d'.' -f2- | rev)
    pandoc -f markdown+hard_line_breaks -o "${base_name}.pdf" <(sed '/^\/\//d' "$1")
}

s6db() {
    local DATAPATH="/home/${USER}/.local/share/s6"
    local RCPATH="${DATAPATH}/rc"
    local DBPATH="${RCPATH}/compiled"
    local SVPATH="${DATAPATH}/sv"
    local SVDIRS="/tmp/${USER}/s6-rc/servicedirs"
    local TIMESTAMP=$(date +%s)

    if ! s6-rc-compile "${DBPATH}"-"${TIMESTAMP}" "${SVPATH}"; then
        echo "Error compiling database. Please double check the ${SVPATH} directories."
        return 1
    fi

    if [ -e "/tmp/${USER}/s6-rc" ]; then
        for dir in "${SVDIRS}"/*; do
            if [ -e "${dir}/down" ]; then
                s6-svc -x "${dir}"
            fi
        done
        s6-rc-update -l "/tmp/${USER}/s6-rc" "${DBPATH}"-"${TIMESTAMP}"
    fi

    if [ -d "${DBPATH}" ]; then
        ln -sf "${DBPATH}"-"${TIMESTAMP}" "${DBPATH}"/compiled && mv -f "${DBPATH}"/compiled "${RCPATH}"
    else
        ln -sf "${DBPATH}"-"${TIMESTAMP}" "${DBPATH}"
    fi

    echo "==> Switched to a new database for ${USER}."
    echo "    Remove any old unwanted/unneeded database directories in ${RCPATH}."
}

fonts() {
    fc-list -b | python3 -c '
import sys
import re
for font in sys.stdin.read().strip().split("\n\n"):
  names = None
  styles = None
  filename = None
  for line in font.splitlines():
    line = line.strip()
    matches = re.findall(r"\"([^\"]+)\"", line)
    if line.startswith("family: "):
      if names is None:
        assert matches, f"Error in line: {line}"
        names = matches
    elif line.startswith("fullname: "):
      assert matches, f"Error in line: {line}"
      names = matches
    elif line.startswith("file: "):
      assert matches, f"Error in line: {line}"
      filename = matches[0]
  assert names is not None, f"Error in font: {font}"
  assert filename is not None, f"Error in font: {font}"
  for name in names:
    print(f"{name} \1:\1 {filename}")
' | fzf --preview 'echo {} | sed "s/ "'$'\1''":"'$'\1''" /\n/"' | sed 's/^.* '$'\1'':'$'\1'' //' | xargs -I% fontview '%'
}

ocr() {
    ~/.config/sway/ocr.sh "$@"
}

gnirehtet-restart() {
    local serial
    serial=$(~/.local/share/scripts/adb_choose.sh)
    if [[ "$?" -ne 0 ]]; then
        echo "No ADB device found."
        return 1
    fi
    bash -c "gnirehtet stop ${serial} && source ~/.local/share/s6/config/gnirehtet.conf && exec gnirehtet start ${serial} \$OPTS"
}

adb-display() {
    if [[ "$#" -ne 1 ]] || ( [[ "$1" != "on" ]] && [[ "$1" != "off" ]] ); then
        echo "Provide either \"on\" or \"off\" as argument"
        return 1
    fi
    local arg=0
    if [[ "$1" = "on" ]]; then
        arg=2
    fi
    local serial
    serial=$(~/.local/share/scripts/adb_choose.sh)
    if [[ "$?" -ne 0 ]]; then
        echo "No ADB device found."
        return 1
    fi
    local dexfile=$(mktemp)
    base64 -d <<< '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OwAhTGphdmEvbGFuZy9Ob1N1Y2hNZXRob2RFeGNlcHRpb247ABJMamF2YS9sYW5nL09iamVjdDsAKExqYXZhL2xhbmcvUmVmbGVjdGl2ZU9wZXJhdGlvbkV4Y2VwdGlvbjsAEkxqYXZhL2xhbmcvU3RyaW5nOwAZTGphdmEvbGFuZy9TdHJpbmdCdWlsZGVyOwASTGphdmEvbGFuZy9TeXN0ZW07AC1MamF2YS9sYW5nL3JlZmxlY3QvSW52b2NhdGlvblRhcmdldEV4Y2VwdGlvbjsAGkxqYXZhL2xhbmcvcmVmbGVjdC9NZXRob2Q7AAdTREtfSU5UAARUWVBFAAFWAAJWTAASW0xqYXZhL2xhbmcvQ2xhc3M7ABNbTGphdmEvbGFuZy9PYmplY3Q7ABNbTGphdmEvbGFuZy9TdHJpbmc7ABthbmRyb2lkLnZpZXcuU3VyZmFjZUNvbnRyb2wABmFwcGVuZAAHZm9yTmFtZQARZ2V0QnVpbHRJbkRpc3BsYXkAGmdldEdldEJ1aWx0SW5EaXNwbGF5TWV0aG9kABdnZXRJbnRlcm5hbERpc3BsYXlUb2tlbgAJZ2V0TWV0aG9kAAZpbnZva2UABG1haW4AA291dAAIcGFyc2VJbnQABXByaW50AA9wcmludFN0YWNrVHJhY2UAE3NldERpc3BsYXlQb3dlck1vZGUACHRvU3RyaW5nAAV2YWx1ZQAHdmFsdWVPZgCbAX5+RDh7ImJhY2tlbmQiOiJkZXgiLCJjb21waWxhdGlvbi1tb2RlIjoiZGVidWciLCJoYXMtY2hlY2tzdW1zIjpmYWxzZSwibWluLWFwaSI6MSwic2hhLTEiOiJmYWNlZGY0MWJiZDI4YjU2M2QxZTllMDljNWY3MmQ3YzVjYTU5OGQ1IiwidmVyc2lvbiI6IjguMi4yLWRldiJ9AAIFATccARgKAgUBNxwBGA0CBAE3HAIXFBcAAQAFAAAaAIiABPAHAYGABLAIAQmgBgEKnAcBiQHICAAAAAAAAAABAAAA0AkAAAEAAADYCQAAAQAAAOAJAAAMCgAAAQAAAAIAAAAAAAAAAAAAACAKAAADAAAAGAoAAAQAAAAQCgAAEAAAAAAAAAABAAAAAAAAAAEAAAA6AAAAcAAAAAIAAAAZAAAAWAEAAAMAAAANAAAAvAEAAAQAAAAEAAAAWAIAAAUAAAARAAAAeAIAAAYAAAABAAAAAAMAAAEgAAAFAAAAIAMAAAMgAAAFAAAABgUAAAEQAAAGAAAAOAUAAAIgAAA6AAAAZgUAAAQgAAADAAAA0AkAAAAgAAABAAAA6gkAAAMQAAAEAAAADAoAAAYgAAABAAAAKAoAAAAQAAABAAAAUAoAAA==' > "$dexfile"
    adb -s "$serial" push "$dexfile" /sdcard/DisplayToggle.dex > /dev/null
    adb -s "$serial" shell CLASSPATH=/storage/emulated/0/DisplayToggle.dex app_process / DisplayToggle "$arg" > /dev/null
    adb -s "$serial" shell rm /sdcard/DisplayToggle.dex > /dev/null
}

source ~/.config/broot/launcher/bash/br

if [[ ! -v DISABLE_HIST ]]; then
    if [[ -f ~/.bash-preexec.sh ]]; then
        source ~/.bash-preexec.sh
        eval "$(atuin init bash --disable-up-arrow)"
    fi
else
    unset HISTFILE
    HISTSIZE=0
    echo "History disabled."
fi
