# Get the total duration of the input file

duration=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nokey=1 input.mp4)

# Start a background process to read progress and update a bar
mkfifo /tmp/progress_pipe

while read -r line; do
    if [[ $line =~ out_time_ms=([0-9]+) ]]; then
        current_time=${BASH_REMATCH[1]}
        percent=$(awk "BEGIN {printf \"%.0f\", ($current_time / ($duration * 1000)) * 100}")
        printf "\rProgress: [%-20s] %d%%" $(head -c $((percent / 5)) < /dev/zero | tr '\0' '#') $percent
    fi
done < /tmp/progress_pipe &

# mkfifo creates a named pipe (also called a FIFO), which is a special file used for inter-process communication (IPC).
#
# What it does: It creates a file in the filesystem that acts as a communication channel. One process can write data to this file, and another process can read that data from it.
#
# Why it's used: In the FFmpeg progress script, mkfifo /tmp/progress_pipe creates a pipe. FFmpeg writes its progress updates to this pipe (-progress /tmp/progress_pipe), while the background loop in the script reads from the same pipe to get the current status and update the progress bar.
#
# The key point is that data flows through the pipe from one process to another, enabling the script to monitor the running FFmpeg process.

# Run FFmpeg with the progress output directed to the pipe
ffmpeg -i input.mp4 -progress /tmp/progress_pipe output.mp3

# Clean up
rm /tmp/progress_pipe
printf "\nConversion complete!\n"   
