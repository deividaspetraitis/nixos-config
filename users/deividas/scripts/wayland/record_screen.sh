#!/usr/bin/env bash

# Temporary filenames
NAME=$(date +'recording_%Y-%m-%d-%H%M%S.png')
VIDEO_FILE="/tmp/$NAME.mp4"
GIF_FILE="$HOME/Documents/$NAME.gif"

# Ensure required tools are installed
if ! command -v wf-recorder &> /dev/null || ! command -v slurp &> /dev/null || ! command -v wl-copy &> /dev/null || ! command -v ffmpeg &> /dev/null; then
    notify-send "Error" "Please install wf-recorder, slurp, wl-copy, and ffmpeg."
    exit 1
fi

# Select an area with slurp
GEOMETRY=$(slurp)
if [ -z "$GEOMETRY" ]; then
    notify-send "Recording canceled" "No area was selected."
    exit 1
fi

# Notify the user and start recording
notify-send "Recording started"
wf-recorder -g "$GEOMETRY" -f "$VIDEO_FILE"

# Notify recording stopped
notify-send "Recording stopped. Converting to GIF..."

# Convert the video to GIF
ffmpeg -i "$VIDEO_FILE" -vf "fps=15,scale=640:-1:flags=lanczos" -c:v gif "$GIF_FILE"

if [ $? -ne 0 ]; then
    notify-send "Error" "Failed to convert video to GIF."
    exit 1
fi

# Copy the GIF to the clipboard
wl-copy < "$GIF_FILE"

if [ $? -ne 0 ]; then
    notify-send "Error" "Failed to copy GIF to clipboard."
    exit 1
fi

# Notify completion
notify-send "GIF ready!" "Saved to $GIF_FILE and copied to clipboard."

# Optional: Clean up temporary video file
rm "$VIDEO_FILE"
