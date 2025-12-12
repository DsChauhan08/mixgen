#!/bin/bash

cut_audio() {
  in="$1"
  start="$2"
  end="$3"
  suffix="$4"

  base="${in%.mp3}"
  out="${base}_${suffix}.mp3"

  ffmpeg -y -i "$in" -ss "$start" -to "$end" -acodec libmp3lame -b:a 192k "$out"
}

# 1 https://youtu.be/16nZ6K7sim4
cut_audio "1.mp3" "0:00" "0:23" "cut"

# 2 https://youtu.be/wnJ6LuUFpMo
cut_audio "2.mp3" "0:45" "1:05" "cut"

# 3 https://youtu.be/97k_BD4XkFE
cut_audio "3.mp3" "0:33" "0:55" "part1_cut"
cut_audio "3.mp3" "2:23" "2:40" "part2_cut"

# 4 https://youtu.be/LwjR20lX4aY
cut_audio "4.mp3" "0:45" "1:11" "cut"

# 5 https://youtu.be/dRLwMAGMJnQ
cut_audio "5.mp3" "2:53" "3:20" "cut"

# 6 https://youtu.be/oAVhUAaVCVQ
cut_audio "6.mp3" "1:26" "2:03" "cut"

# 7 https://youtu.be/BkA0lq-0f14
cut_audio "7.mp3" "1:02" "1:37" "cut"

# 8 https://youtu.be/qny5OwwoYVE
cut_audio "8.mp3" "0:05" "0:57" "cut"

# 9 https://youtu.be/jZyAB2KFDls
cut_audio "9.mp3" "0:38" "1:17" "cut"

# 10 https://youtu.be/DiItGE3eAyQ
cut_audio "10.mp3" "0:10" "0:48" "cut"

# 11 https://youtu.be/OulN7vTDq1I
cut_audio "11.mp3" "0:37" "1:12" "cut"

# 12 https://youtu.be/pElk1ShPrcE
cut_audio "12.mp3" "1:22" "2:04" "cut"

# 13 https://youtu.be/iy8q8jRC2yU
cut_audio "13.mp3" "0:16" "0:56" "cut"

# 14 https://youtu.be/HfaC9nWKrxw
cut_audio "14.mp3" "0:34" "1:05" "cut"

# 15 https://youtu.be/9bZkp7q19f0
cut_audio "15.mp3" "0:52" "1:23" "cut"

# 16 https://youtu.be/CCF1_jI8Prk
cut_audio "16.mp3" "0:10" "0:45" "cut"
