#!/usr/bin/env bash
if [ "$#" -gt 2 ] || [ "$#" -eq 0 ]; then
    echo "Usage: ocr <LANG> [IMAGE_PATH]"
    exit 1
fi
name=/tmp/ocr_"$(date +'%Y-%m-%d_%H-%M-%S.png')"
if [ "$#" -eq 2 ]; then
    name="$2"
else
    grim -g "$(slurp)" - > "$name"
    if [ "$?" -ne 0 ]; then
        exit
    fi
fi
res=$(tesseract "$name" - -l "$1" 2> /dev/null)
echo "$res"
echo -n "$res" | wl-copy -n
if [ "$#" -ne 2 ]; then
    rm "$name"
fi
