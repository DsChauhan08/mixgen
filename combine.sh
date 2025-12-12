#!/bin/bash

# CONFIG
CROSSFADE=0.6 # seconds
TARGET_DB=-14 # loudness target (LUFS)
FINAL="mashup_final.mp3"

# Collect files numerically sorted (handles 1_cut, 2_cut, 3_part1_cut, etc.)
files=($(ls *_cut*.mp3 | sort -V))

if [ ${#files[@]} -eq 0 ]; then
  echo "No cut files found."
  exit 1
fi

echo "Files detected:"
printf '%s\n' "${files[@]}"
echo

# Temporary working audio
temp="__temp__.mp3"
out="__out__.mp3"

# Start with first file normalized
echo "Normalizing first: ${files[0]}"
ffmpeg -y -i "${files[0]}" -filter:a "loudnorm=I=$TARGET_DB" "$temp"

# Loop for crossfade + normalization
for ((i = 1; i < ${#files[@]}; i++)); do
  next="${files[$i]}"
  echo
  echo "Processing: $next"

  # Step 1: Normalize the next audio
  echo "Normalizing..."
  ffmpeg -y \
    -i "$next" \
    -filter:a "loudnorm=I=$TARGET_DB" \
    "__norm__.mp3"

  # Step 2: Crossfade current temp with the next
  echo "Crossfading ${files[$i - 1]} -> $next"
  ffmpeg -y \
    -i "$temp" \
    -i "__norm__.mp3" \
    -filter_complex "acrossfade=d=$CROSSFADE:c1=tri:c2=tri" \
    "$out"

  # Replace temp
  mv "$out" "$temp"
  rm "__norm__.mp3"
done

mv "$temp" "$FINAL"
echo
echo "DONE — Final mashup saved as: $FINAL"
