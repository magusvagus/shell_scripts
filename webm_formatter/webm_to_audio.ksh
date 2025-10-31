#!/bin/ksh

YT_DLP_PROCESS=$(ps aux | grep y[t]-dlp )
SECOND_WORD=$(echo "$YT_DLP_PROCESS" | awk '{print $2}' )   

if [[ -n "$YT_DLP_PROCESS" ]];then
	printf "[ ERROR ] Can't proceed, yt-dlp process running. PID: %s\n" "$SECOND_WORD";
	exit 1;
fi

WEBM_COUNT=0;

for f in *; do
    if [[ "$f" == *.webm ]]; then
        printf "%.30s... .webm\n" "$f";
		((WEBM_COUNT++));
    fi
done   

printf "\n[ Scanned ]\n";

ANSWER=0
LOOP=0

# test for existing formatted directory
if [[ ! -d formatted || ! -d original_files ]]; then
	printf "formatted/ original_file directory not found -> creating\n";
	mkdir formatted
	mkdir original_files
fi

while ((LOOP == 0));do
	printf ">\t %d .webm file/s detected.\n" "$WEBM_COUNT"
	printf ">\t do you want to convert them into:\n"
	printf ">\n"
	printf ">\t 1. flac\n"
	printf ">\t 2. mp4\n"
	printf ">\t q. Quit\n"
	printf ">\n"
	printf "> choose:"

	read ANSWER

	if [[ "$ANSWER" == 1 ]];then
		printf "[ Converting... ]\n";
		printf ">\t webm -> flac\n";

		for FILE in *.webm; do
			ffmpeg -i "$FILE" -c:a flac "${FILE%.webm}.flac";
			mv "${FILE%.webm}.flac" formatted;

		done
		((LOOP++));

	elif [[ "$ANSWER" == 2 ]];then
		printf "[ Converting... ]\n";
		printf ">\t webm -> mp4\n";

		for file in *.webm; do
			ffmpeg -i "$FILE" "${FILE%.webm}.mp4";
			mv "${FILE%.webm}.mp4" formatted;
		done
		((LOOP++));

	elif [[ "$ANSWER" == "q" ]];then
		printf ">\n> Quitting...\n";
		exit 0;

	else
		echo "\n\n[ ERROR ] invalid input";
	fi
done

printf "[ OK ] Finished.\n";



