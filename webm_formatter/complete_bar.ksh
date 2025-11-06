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
	typeset _number_of_loops
	typeset _result
	typeset _symbol

	_number_of_loops="$1"
	_result="$2"
	_symbol="$3"

	for i in $(seq 1 "$_number_of_loops"); do
		_result="${_result}${_symbol}"   
	done
	printf "%s" "$_result"
}

# variables for testing purposes
full_percent=393 # seconds
printf "Amount of seconds: %d\n" "$full_percent"

conversion_rate=3.0
printf "Conversion rate: %.2f\n" "$conversion_rate"

# header to name the process bar
header="[PROCESS]"

# subtract header text from cols
terminal_with=$(tput cols)
terminal_with=$(printf "%s - ( %s - 1 )\n" "$terminal_with" "${#header}" | bc -l)
printf "terminal with: %d\n" "$terminal_with"

symbol="|"
TIME=1

# main loop
total_duration=$(duration "$full_percent" "$conversion_rate")
while true; do
	if [[ "$TIME" -ne "$total_duration" ]]; then

		time_percent=$(time_perc "$total_duration" "$TIME")
		bar_percent=$(bar_perc "$terminal_with" "$time_percent")

		result=$(draw_bar "$bar_percent" "$result" "$symbol")
		printf "\r%s%s" "$header" "$result"
		result=""
	else
		printf "Done\n"
		exit 0
	fi

	# printf "\n"
	# printf "total duration:		 %-03d sec\n" "$total_duration"
	# printf "current time: 		 %-03d sec\n" "$TIME"
	# printf "current percent:	 %-03d %%\n" "$time_percent"
	#
	# printf "\n"
	#
	# printf "terminal with:		 %-03d char\n" "$terminal_with"
	# printf "current percent:	 %-03d char %%\n" "$bar_percent"

	((TIME++))
	sleep 1
done


