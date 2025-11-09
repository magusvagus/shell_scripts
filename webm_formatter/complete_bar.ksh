#!/bin/ksh

# needs to be started in background -> &
function format_file
{
	typeset _error
	typeset _input_file

	_error=$(mktemp)
	_input_file="$1"

	touch /tmp/progress

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
		rm /tmp/progress 2> /dev/null
	fi
}

function print_conversion_speed
{
	typeset _extract_line
	typeset _time_float

	_extract_line=$(cat "/tmp/progress.log" | grep speed | tail -n 1)

	# this works, gives back just the speed rate
	# returns float
	# TODO BUG - sed sometimes extracts number with appended x ( 33x) instead of
	# the number itself, needs fixing
	_time_float=$(echo $_extract_line | sed -E 's/.*speed=([0-9]*\.?[0-9]+)x.*/\1/')

	printf "%s" "$_time_float"
}

function file_duration_lenght
{
	typeset _input_file
	typeset _duration_float
	typeset _error

	_input_file="$1"

	_duration_float=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$_input_file" 2> /dev/null)

	# turn $duration into an integer from float

	# catch duration error
	if [[ ! -n "$_duration_float" ]]; then
		return 1
	fi

	# return
	printf "%.0f" "$_duration_float" # Rounds to nearest integer
}

# calculate the final duration of the conversion
# based on the file lenght in seconds and conversion rate
function converted_duration
{
	typeset _file_duration
	typeset _conversion_rate
	typeset _final_duration

	_file_duration="$1"
	_conversion_rate="$2"

	_final_duration=$(printf "%0.f / %0.f\n" "$_file_duration" "$_conversion_rate" | bc -l)
	printf "%0.f" "$_final_duration"
}

function time_perc
{
	typeset _result
	typeset _percent
	typeset _total_lenght
	typeset _current_time

	_total_lenght="$1"
	_current_time="$2"
	
	_result=$(printf "%.6f / %.6f\n" "$_current_time" "$_total_lenght" | bc -l)
	_percent=$(printf "%.6f * 100\n" "$_result" | bc -l)
	printf "%.0f\n" "$_percent"
}

function bar_perc
{
	typeset _result
	typeset _bar_percent
	typeset _full_percent
	typeset _current_percent

	_full_percent="$1"
	_current_percent="$2"

	_result=$(printf "%.6f / 100\n" "$_current_percent" | bc -l)
	_bar_percent=$(printf "%.6f * %.6f\n" "$_result" "$_full_percent" | bc -l)
	printf "%.0f\n" "$_bar_percent"
}

function draw_bar
{
	# experimental
	# TODO move _terminal width out of function, and use it as a
	# fucntion variable
	typeset _number_of_loops
	typeset _result
	typeset _symbol
	typeset _terminal_width
	typeset _space
	typeset _end

	_terminal_width=$(tput cols)
	_number_of_loops="$1"
	_result="$2"
	_symbol="$3"
	_space=" "
	_end="]"

	for i in $(seq 1 "$_number_of_loops"); do
		_result="${_result}${_symbol}"   
	done

	# TODO creates bug, and draws to much white spaces
	#
	# _terminal_width=$(printf "%s - %s -20\n" "$_terminal_width" "${#_result}" | bc -l)
	#
	# for i in $(seq 1 "$_terminal_width"); do
	# 	_result="${_result}${_space}"
	# done

	#printf "%s" "${_result}${_end}"

	printf "%s" "${_result}"
}


input_file="Unreal.flac"
file_path="$(pwd)/$input_file"

symbol="|"
TIME=1

# remove leftover files, in case script crashed previously
rm /tmp/done_check.lock 2> /dev/null

# for testing
rm confrs.mp3  2> /dev/null
#touch /tmp/progress.log


# start conversion
format_file "$input_file" & 
printf "==== input file: %s\n" "$input_file"

conversion_rate=$(print_conversion_speed)
printf "==== conversion rate: %s\n" "$conversion_rate"

file_duration=$(file_duration_lenght "$input_file")
printf "==== file duration: %s\n" "$file_duration"

# catch error
if [[ "$_duration_float" -eq -1 ]]; then
	printf "[ ERROR ] Could not define video lenght."
fi

total_duration=$(converted_duration "$file_duration" "$conversion_rate")
# total_duration=333
printf "==== total duration: %s\n" "$total_duration"

# main loop
while true; do
	if [[ "$TIME" -ne "$total_duration" ]]; then

		# might be too much, but makes the bar dynamic
		# based on the current window width
		terminal_width=$(tput cols)
		time_percent=$(time_perc "$total_duration" "$TIME")

		# header to name the process bar
		header=$(printf "[ ffmpeg ][ %03s%% ][" "$time_percent")

		# subtract header text from cols
		terminal_width2=$(printf "%s - ( %s - 4 )\n" "$terminal_width" "${#header}" | bc -l)

		bar_percent=$(bar_perc "$terminal_width2" "$time_percent")

		result=$(draw_bar "$bar_percent" "$result" "$symbol")
		printf "\r%s%s" "$header" "$result"
		result=""
	else
		printf "Done\n"
		exit 0
	fi

	((TIME++))
	sleep 1
done


