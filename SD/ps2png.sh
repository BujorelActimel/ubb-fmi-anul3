#!/bin/bash
for f in plots/lab1/*.ps; do
    convert -rotate 90 -background white -flatten "$f" "${f%.ps}.png" && rm "$f"
done
