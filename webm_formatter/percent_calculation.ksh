#!/bin/ksh

function duration
{
	typeset _total_time
	typeset _duration
	typeset _current_time

	_duration="$1"
	_current_time="$2"

	_total_time=$(printf "%.0f / %.0f\n" "$_duration" "$_current_time" | bc -l)
	printf "%0.f" "$_total_time"
}

function time_perc
{
	typeset _time_percent
	typeset _time_percent_final
	typeset _total_time
	typeset _current_time

	_total_time="$1"
	_current_time="$2"
	
	_time_percent=$(printf "%.6f / %.6f\n" "$_current_time" "$_total_time" | bc -l)
	_time_percent_final=$(printf "%.6f * 100\n" "$_time_percent" | bc -l)
	printf "%.0f\n" "$_time_percent_final"
}

function bar_perc
{
	typeset _bar_percent
	typeset _bar_percent_total
	typeset _total_percent
	typeset _current_percent

	_total_percent="$1"
	_current_percent="$2"

	_bar_percent=$(printf "%.6f / 100\n" "$_current_percent" | bc -l)
	_bar_percent_total=$(printf "%.6f * %.6f\n" "$_bar_percent" "$_total_percent" | bc -l)
	printf "%.0f\n" "$_bar_percent_total"
}

# variables for testing purposes
full_percent=393 # seconds
printf "Amount of seconds: %d\n" "$full_percent"

conversion_rate=3.0
printf "Conversion rate: %.2f\n" "$conversion_rate"

terminal_with=$(tput cols)
printf "terminal with: %d\n" "$terminal_with"

TIME=0

# main loop
total_duration=$(duration "$full_percent" "$conversion_rate")
while true; do
	printf "\n"
	printf "total duration:		 %-03d sec\n" "$total_duration"
	printf "current time: 		 %-03d sec\n" "$TIME"
	time_percent=$(time_perc "$total_duration" "$TIME")
	printf "current percent:	 %-03d %%\n" "$time_percent"

	printf "\n"

	printf "terminal with:		 %-03d char\n" "$terminal_with"
	bar_percent=$(bar_perc "$terminal_with" "$time_percent")
	printf "current percent:	 %-03d char %%\n" "$bar_percent"

	((TIME++))
	sleep 1
done


