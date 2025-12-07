#!/bin/bash

for f in *.webm; do
  [ -e "$f" ] || continue

  out="${f%.webm}.mp3"

  ffmpeg -i "$f" -vn -ab 192k -ar 44100 -y "$out"

  if [ -f "$out" ]; then
    rm "$f"
  fi
done
