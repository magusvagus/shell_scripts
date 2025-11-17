#!/bin/ksh

# needs to be started in background -> &
function format_flac_to_mp3
{
	typeset _input_file
	typeset _error

	_input_file="$1"
	_error=$(mktemp)

	touch /tmp/progress

	# Capture progress to a temporary file, then extract final speed
	ffmpeg -i "$_input_file" -c:a libmp3lame -q:a 0 confrs.mp3 -progress /tmp/progress.log -nostats -loglevel error 2>$_error

	# catch error msg
	# else confirm end of conversion with temp done_check.lock file
	if [[ -s "$_error" ]]; then
		printf "\n[ ERROR ] Could not convert file.\n[ ERROR ] ErrMsg: "
		# add cosmetic tabs, to the error messages for readability
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

function get_conversion_rate
{
	typeset _extract_line
	typeset _conversion_rate

	# has to be checked in do-while loop for zero 
	# due to a bug/ race condition, as this command sometimes 
	# returns 0 on first run
	while true; do
		_extract_line=$(cat "/tmp/progress.log" | grep speed | tail -n 1)
		_conversion_rate=$(echo $_extract_line | sed -n 's_.*=\([0-9]*\)\..*_\1_p')

		if [[ _conversion_rate -ne 0 ]]; then
			break
		fi
	done

	# return conversion rate
	printf "%s" "$_conversion_rate"
}

function get_file_duration
{
	typeset _input_file
	typeset _file_duration
	typeset _error

	_input_file="$1"

	_file_duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$_input_file" 2> /dev/null)

	# catch duration error
	if [[ ! -n "$_file_duration" ]]; then
		return 1
	fi

	# return file duration
	printf "%.0f" "$_file_duration" # Rounds to nearest integer
}

# calculate the final duration of the conversion process
# based on the file lenght in seconds and conversion rate
function get_converted_duration
{
	typeset _file_duration
	typeset _conversion_rate
	typeset _final_duration
	typeset _input_file

	_input_file="$1"

	_conversion_rate=$(get_conversion_rate)
	_file_duration=$(get_file_duration "$_input_file")
	_final_duration=$(printf "%0.f / %0.f\n" "$_file_duration" "$_conversion_rate" | bc -l)

	# return final duration
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

	# return percent
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

	# return bar percent
	printf "%.0f\n" "$_bar_percent"
}

function draw_bar
{
	typeset _time_percent
	typeset _terminal_width
	typeset _header
	typeset _max_bar_length
	typeset _current_bar_length
	typeset _bar
	typeset _space
	typeset _symbol
	typeset _end

	# get current time percentage
	_time_percent="$1"

	# bar elements
	_header=$(printf "[ ffmpeg ][ %03s%% ][" "$_time_percent")
	_bar=""
	_space=" "
	_symbol="|"
	_end="]"

	# bar calculation
	_terminal_width=$(tput cols)
	_max_bar_length=$(printf "%d - %d - 1\n" "$_terminal_width" "${#_header}" | bc -l)
	_current_bar_length=$(bar_perc "$_max_bar_length" "$_time_percent")

	# draw bar
	
	# append space char N times to _bar
	for i in $(seq 0 "$_current_bar_length"); do
		_bar="${_bar}${_symbol}"   
	done

	# TODO creates bug, and draws to much white spaces
	#
	# _terminal_width=$(printf "%s - %s -20\n" "$_terminal_width" "${#_result}" | bc -l)
	#
	# for i in $(seq 1 "$_terminal_width"); do
	# 	_result="${_result}${_space}"
	# done

	#printf "%s" "${_result}${_end}"


	printf "\r%s" "${_header}${_bar}" # print final bar
	tput el # reset bar/ clean buffer
}


input_file="Unreal.flac"
file_path="$(pwd)/$input_file"

TIME=-1

# remove leftover files, in case script crashed previously
rm /tmp/done_check.lock 2> /dev/null

# for testing
rm confrs.mp3  2> /dev/null
#touch /tmp/progress.log


# start conversion
format_flac_to_mp3 "$input_file" & 


# # catch error
# if [[ "$_duration_float" -eq 1 ]]; then
# 	printf "[ ERROR ] Could not define video lenght."
# fi

total_duration=$(get_converted_duration "$input_file")

# main loop
while true; do
	if [[ "$TIME" -ne "$total_duration" ]]; then
		# check if process finished early
		if [[ ! -e "/tmp/done_check.lock" ]];then
			((TIME++))
			# get current window width
			time_percent=$(time_perc "$total_duration" "$TIME")
			draw_bar "$time_percent"
		else
			# if program finished early set bar to 100
			# draw and finish
			TIME=$total_duration
			time_percent=100
			draw_bar "$time_percent"
		fi
	else
		printf "Done\n"
		exit 0
	fi

	sleep 1
done


