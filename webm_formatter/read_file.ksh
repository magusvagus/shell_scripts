#!/bin/ksh

# get duration
duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 gothic.webm)
# turn duration into int from float
int=$(printf "%.0f" "$duration")  # Rounds to nearest integer
minutes=$(( int / 60 ))

check=false
file_num=0


function fp 
{
	((files++))
	ffmpeg -i gothic.webm -vn -ab 128k -ar 44100 -y output.mp3 > /dev/null
	check=true
}

fp() &

round=0
while [[ "$check" != "true" ]]; do
	printf "\r working %d" "$round"
	((round++))
done

# prints minutes of video
echo "$result"



