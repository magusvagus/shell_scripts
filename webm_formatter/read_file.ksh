#!/bin/ksh

# remove leftover files, in case script crashed
rm /tmp/done.lock > /dev/null

# for testing
rm confrs.mp3

# get duration
duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 gothic.webm)

# turn duration into int from float
int=$(printf "%.0f" "$duration")  # Rounds to nearest integer
minutes=$(( int / 60 ))

check=false
file_num=0


function fp 
{
	# only output stderr
	ffmpeg -nostdin -loglevel error -i rs.flac -c:a libmp3lame -q:a 0 confrs.mp3 2>&1 1>/dev/null   
	touch /tmp/done.lock
	((files++))
	check=true
	echo "function done"
	sleep 2
	rm /tmp/done.lock
}

fp &

round=0
while [[ ! -f "/tmp/done.lock" ]]; do
	printf "\r working %d" "$round"
	((round++))
done
printf "-----------DONE---------------\n"

# prints minutes of video
echo "$result"
rm /tmp/done.lock



