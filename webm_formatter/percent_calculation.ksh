#!/bin/ksh

# typeset a
# result=$(echo "3.5 + 2.1" | bc -l)
# echo $result   
# b=(( 2.1 ))
#

full_percent=393 # seconds
printf "Amount of seconds: %d\n" "$full_percent"

conversion_rate=3.0
printf "Conversion rate: %.2f\n" "$conversion_rate"

terminal_with=$(tput cols)
printf "terminal with: %d\n" "$terminal_with"

function duration
{
	total_time=$(printf "%.0f / %.0f\n" "$1" "$2" | bc -l)
	printf "%d" "$total_time"
}

function time_perc
{
	# $1 -> total
	# $2 -> current time
	typeset _time_percent=$(printf "%.6f / %.6f\n" "$2" "$1" | bc -l)
	typeset _time_percent2=$(printf "%.6f * 100\n" "$_time_percent" | bc -l)
	printf "%.0f\n" "$_time_percent2"
}

function bar_perc
{
	# $1 -> total
	# $2 -> percent
	typeset _bar_percent=$(printf "%.6f / 100\n" "$2" | bc -l)
	typeset _bar_percent2=$(printf "%.6f * %.6f\n" "$_bar_percent" "$1" | bc -l)
	printf "%.0f\n" "$_bar_percent2"
}

TIME=0

duration_var=$(duration "$full_percent" "$conversion_rate")
while true; do
	printf "\n"
	printf "total duration:		 %-03d sec\n" "$duration_var"
	printf "current time: 		 %-03d sec\n" "$TIME"
	time_percent=$(time_perc "$duration_var" "$TIME")
	printf "current percent:	 %-03d %%\n" "$time_percent"

	printf "\n"

	printf "terminal with:		 %-03d char\n" "$terminal_with"
	bar_percent=$(bar_perc "$terminal_with" "$time_percent")
	printf "current percent:	 %-03d char\n" "$bar_percent"

	((TIME++))
	sleep 1
done


# a=1.72
# b=1.71
#
# if [ "$(printf '%s > %s\n' "$a" "$b" | bc -l)" -eq 1 ]; then
#    echo "a is greater than b"
# else
#    echo "a is not greater than b"
#fi   





