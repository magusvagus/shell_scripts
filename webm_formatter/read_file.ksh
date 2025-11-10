#!/bin/ksh

# get duration
function file_duration_lenght
{
	typeset _minutes
	typeset _input_file
	typeset _duration_float

	_input_file="$1"

	_duration_float=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$_input_file" 2> /dev/null)
	# turn $duration into an integer from float

	_minutes=$(printf "%s / 60\n" "$_duration_float" | bc -l)
	# catch duration error
	if [[ -n "$_duration_float" ]]; then
		printf "%s lenght: %.0f min\n" "$_input_file" "$_minutes"
	else
		printf "[ ERROR ] Could not define video lenght."
	fi

	# return
	printf "%.0f" "$_duration_float" # Rounds to nearest integer
}

function format_file
{
	typeset _error
	typeset _input_file

	_error=$(mktemp)
	_input_file="$1"

	# Capture progress to a temporary file, then extract final speed
	ffmpeg -i "$_input_file" -c:a libmp3lame -q:a 0 confrs.mp3 -progress /tmp/progress.log -nostats -loglevel error 2>$_error

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

# remove leftover files, in case script crashed previously
rm /tmp/done_check.lock 2> /dev/null

# for testing
rm confrs.mp3  2> /dev/null

input_file="Unreal.flac"
file_path="$(pwd)/$input_file"
#input_file="$(pwd)/fakeErrorFile.flac"

check=false
file_num=0

# do not move out of global scope, otherwise (i dont know why)
# the cat command below, says that file not found.
touch /tmp/progress.log



# NOTE: This conversion below is quite slow, needs to be
# improved

# if cat throws error, remove line "rm /tmp/progress.log"
# below or above
function print_conversion_speed
{
	typeset _extract_line
	typeset _time_float

	_extract_line=$(cat "/tmp/progress.log" | grep speed | tail -n 1)

	# this works, gives back just the speed rate
	# returns float
	_time_float=$(echo $_extract_line | sed -n 's_.*=\([0-9]*\)\..*_\1_p')
	#_time_float=$(echo $_extract_line | grep -o '[0-9]*')

	printf "%s" "$_time_float"
}


format_file "$input_file" & 
time_float=$(print_conversion_speed)
file_duration=$(file_duration_lenght "$input_file")
printf "%s\n" "$file_duration"

# TODO try -e to just check if file exists
round=0

while [[ ! -f "/tmp/done_check.lock" ]]; do
	# check if there is no err file
	if [[ ! -f "/tmp/err.lock" ]]; then
		#printf "\r working %d" "$round"
		printf "\rextracted speed: %s" "$time_float"
		sleep 1
		((round++))
	fi
done

printf "\n-----------DONE---------------\n"

# prints minutes of video
rm /tmp/done_check.lock 2> /dev/null
rm /tmp/progress.log
exit 0



