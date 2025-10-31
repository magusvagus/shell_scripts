#!/bin/ksh

rm /tmp/fpeg_test
rm output.mp3
mkfifo /tmp/fpeg_test

total_duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 gothic.webm)

ffmpeg -i gothic.webm -progress /tmp/fpeg_test -f mp3 output.mp3 &

echo "test"
tail -f /tmp/fpeg_test

echo "test2"

# while read line
# do
# 	if [[ $key == "out_time_ms" ]]; then
# 	printf "LINE %s\n" "$line"
# 	fi
# done < /tmp/fpeg_test

rm /tmp/fpeg_test


