#!/bin/ksh

mkfifo /tmp/progress_pipe

ffmpeg -i gothic.webm -progress /tmp/progress_pipe output.mp3 > /dev/null 1>&2
echo "-----------------"
tail -f /tmp/progress_pipe

rm /tmp/progress_pipe

