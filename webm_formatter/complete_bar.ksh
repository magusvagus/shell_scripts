#!/bin/ksh

# calculate the final duration of the conversion
# based on the file lenght in seconds and conversion rate
function duration
{
	typeset _file_duration
	typeset _conversion_rate
	typeset _final_duration

	_file_duration="$1"
	_conversion_rate="$2"

	_final_duration=$(printf "%.0f / %.0f\n" "$_file_duration" "$_conversion_rate" | bc -l)
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

	_terminal_width=$(printf "%s - %s -20\n" "$_terminal_width" "${#_result}" | bc -l)

	for i in $(seq 1 "$_terminal_width"); do
		_result="${_result}${_space}"
	done

	printf "%s" "${_result}${_end}"
}

# variables for testing purposes
full_percent=103 # seconds
printf "Amount of seconds: %d\n" "$full_percent"

conversion_rate=3.0
printf "Conversion rate: %.2f\n" "$conversion_rate"

printf "terminal with: %d\n" "$terminal_with"
printf "terminal with2: %d\n" "$terminal_with2"

symbol="|"
TIME=1

# main loop
total_duration=$(duration "$full_percent" "$conversion_rate")
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


