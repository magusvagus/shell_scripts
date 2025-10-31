#!/bin/ksh

# get duration
duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 gothic.webm)

# turn duration into int from float
int=$(printf "%.0f" "$duration")  # Rounds to nearest integer

result=$(( int / 60 ))

# prints minutes of video
echo "$result"



