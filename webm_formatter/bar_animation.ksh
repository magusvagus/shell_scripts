#!/bin/ksh

X=$(tput cols)
result=""
i=0
reverse=false
symbol=">"

while true; do
	sleep 0.001
	if [[ "$reverse" == "false" ]]; then
		if [[ $i -eq $X ]]; then
			reverse=true
		else
			result="${result}${symbol}"   
			((i++))
			printf "\r%s" "$result"
		fi

	elif [[ "$reverse" == "true" ]]; then
		if [[ $i -eq 0 ]]; then
			reverse=false
		else
			result="${result%?}" 
			((i--))
			printf "\r%s\033[K" "$result"
			# or use instead of '\033[K'
			# tput el
		fi	
	fi
done   



