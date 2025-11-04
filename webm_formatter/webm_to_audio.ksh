#!/bin/ksh

# NOTE CHECK OUT COPROCESSES IN KSH
#

# Check for running yt-dlp processes, in case a file is still downloading
# throw ERR
YT_DLP_PROCESS=$(ps aux | grep y[t]-dlp )
SECOND_COLUMN=$(echo "$YT_DLP_PROCESS" | awk '{print $2}' )   

if [[ -n "$YT_DLP_PROCESS" ]];then
	printf "[ ERROR ] Can't proceed, yt-dlp process running. PID: %s\n" "$SECOND_COLUMN";
	exit 1;
fi

# TODO if script is run by default do NOT create directories and 
# conf file. so it can be used in a quick manner if needed

# check for config file with path
PATH_TEST=$(pwd);

if [[ ! -e formatter.conf ]]; then
	printf "[ !! ] Default path not set\n"
	printf "[ !! ] Config file not set\n"
	printf "Current path: $PATH_TEST\nUse current path? [y/n] "
	read INPUT

	if [[ $INPUT == "n" ]]; then
		printf "\nSet custom path, use full path: "
		read INPUT
		touch formatter.conf
		printf "PATH_DIR=\"%s\"" "$INPUT" >> formatter.conf
		NEW_PATH=$INPUT

	elif [[ $INPUT == "y" ]]; then
		printf "Using current path: $PATH_TEST\n"
		touch formatter.conf
		printf "PATH_DIR=\"%s\"" "$PATH_TEST" >> formatter.conf
		NEW_PATH=$PATH_TEST

	else
		printf "[ Quit ] Invalid input\n"
		exit 1
	fi
fi


# source config file and compare to current path
. ./formatter.conf

# if run in new path ie. format.conf dosent match current file path
if [[ $PATH_TEST != $PATH_DIR ]]; then
	printf "\n[ !! ] Different path detected!\n"
	printf "Current path: $PATH_TEST\nUse current path? [y/n] "
	read INPUT
	if [[ $INPUT == "y" ]]; then
		printf "Set custom path, use full path\n"
		read INPUT
		printf "PATH_DIR='%s'" "$PATH_TEST" >> formatter.conf
	else
		# TODO set option to not use directories
		printf "[ Quit ] Aborting...\n"
		exit 1
	fi
fi

# array of required directories and sub directories
set -A DIRECTORIES "formatted_files" "original_files" "formatted_files/flac" "formatted_files/mp3"

MISSING=false

printf "\nScanning for required directories\n";
for DIR in "${DIRECTORIES[@]}"; do
	if [[ ! -e $DIR ]]; then
		printf "%-23s-> not found\n" "$DIR"
		MISSING=true
	fi
done

# this was made when there were initially more directories
if [[ "$MISSING" == "true" ]]; then
	printf "\nCreate missing directories? [y/n] "
	read INPUT

	if [[ $INPUT == "y" ]]; then
		for DIR in "${DIRECTORIES[@]}"; do
			if [[ ! -e $DIR ]]; then
				mkdir -p "$DIR"
				printf "%-23s-> created\n" "$DIR"
			fi
		done

	else
		# TODO create option to use without required directories
		printf "[ Quit ] Invalid input\n"
		exit 1
	fi
fi


WEBM_COUNT=0;

for i in . ./original_files; do
	for file in "$i"/*.webm;do
		if [[ -e "$file" ]]; then
			printf "%.30s... .webm\n" "$file";
			((WEBM_COUNT++));
		fi
	done
done

printf "\n[ Result ]\n\n";

ANSWER=0
LOOP=0

while ((LOOP == 0));do
	printf "%d .webm file/s detected.\n" "$WEBM_COUNT"
	printf "What do you want to convert them into?:\n"
	printf "\n"
		# NOTE currently turned off
	printf "\t 1. flac\n"
	#printf "\t 2. mp4\n"
			# TODO add option for mp3
	printf "\t q. Quit\n"
	printf "\n"
	printf "choice: "

	read INPUT

	if [[ "$INPUT" == 1 ]];then
		printf "\n[ Converting... ]\n";
		printf "webm -> flac\n";

		mv "*.webm" "original_files" &2> /dev/null

		for FILE in original_files/*.webm; do

			ffmpeg -i "$FILE" -c:a flac "${FILE%.webm}.flac";
			mv *.webm formatted_files
		done
		((LOOP++));

	elif [[ "$INPUT" == 2 ]];then
		printf "\n[ Converting... ]\n";
		printf "webm -> mp4\n";

		# for file in *.webm; do
		# 	ffmpeg -i "$FILE" "${FILE%.webm}.mp4";
		# 	mv "${FILE%.webm}.mp4" formatted_files;
		# done
		# ((LOOP++));

	elif [[ "$INPUT" == "q" ]];then
		printf "\n[ EXIT ] Quitting...\n";
		exit 0;

	else
		echo "\n\n[ ERROR ] invalid input";
	fi
done

printf "[ OK ] Finished.\n";



