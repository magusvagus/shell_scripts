#!/bin/ksh

# remove leftover files, in case script crashed
rm /tmp/done_check.lock 2> /dev/null

# for testing
rm confrs.mp3  2> /dev/null

input_file="rs.flac"
file_path="$(pwd)/$input_file"
#input_file="$(pwd)/notHere.flac"


# get duration
duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$input_file" 2> /dev/null)

# turn $duration into an integer from float
int=$(printf "%.0f" "$duration")  # Rounds to nearest integer
minutes=$(( int / 60 ))


if [[ -n "$duration" ]]; then
	printf "%s lenght: %s min\n" "$input_file" "$minutes"
else
	printf "[ ERROR ] Could not define video lenght."
fi

check=false
file_num=0

touch /tmp/progress.log

function fp 
{

	
	typeset _error=$(mktemp)

	# Capture progress to a temporary file, then extract final speed
	ffmpeg -i "$input_file" -c:a libmp3lame -q:a 0 confrs.mp3 -progress /tmp/progress.log -nostats -loglevel error 2>$_error

	# catch error msg
	if [[ -s "$_error" ]]; then
		printf "\n[ ERROR ] Could not convert file.\n[ ERROR ] ErrMsg: "
		#cat "$_error"
		sed '2,$s/^/ 		  /' "$_error"

		touch /tmp/err.lock
		sleep 2
		rm /tmp/err.lock 2> /dev/null
		return 1
	else

		touch /tmp/done_check.lock
		sleep 2
		rm /tmp/done_check.lock 2> /dev/null
	fi
}

fp & 
_time_left=$(cat "/tmp/progress.log" | grep speed | tail -n 1)

# this works gives back just the seed rate
_time_float=$(echo $_time_left | sed -E 's/.*speed=([0-9]*\.?[0-9]+)x.*/\1/')

round=0
while [[ ! -f "/tmp/done_check.lock" ]]; do
	# check if there is no err file
	if [[ ! -f "/tmp/err.lock" ]]; then
		#printf "\r working %d" "$round"
		printf "\rextracted speed: %s" "$_time_float"
		sleep 1
		((round++))
	fi
done
printf "\n-----------DONE---------------\n"

# prints minutes of video
rm /tmp/done_check.lock 2> /dev/null
exit 0



