#!/bin/bash
dir="${1:?Usage: ps2png.sh <directory>}"
for f in "$dir"/*.ps; do
    convert -rotate 90 -background white -flatten "$f" "${f%.ps}.png" && rm "$f"
done
