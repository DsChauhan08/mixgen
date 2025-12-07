#!/bin/bash

DUR=0.5 # crossfade duration

# Get files sorted numerically by prefix
files=($(ls *_cut.mp3 | sort -V))

# Temporary working file
temp="__temp__.mp3"
final="mashup_final.mp3"

# Start with the first file
cp "${files[0]}" "$temp"

# Loop through remaining files
for ((i = 1; i < ${#files[@]}; i++)); do
  next="${files[$i]}"
  echo "Crossfading: $temp + $next"

  ffmpeg -y \
    -i "$temp" \
    -i "$next" \
    -filter_complex "acrossfade=d=$DUR:c1=tri:c2=tri" \
    "__out__.mp3"

  mv "__out__.mp3" "$temp"
done

mv "$temp" "$final"
echo
echo "DONE: Output saved as $final"
