#!/bin/bash

ffmpeg -i "$1" -vn -f s16le -ac 2 -ar 48000 pipe:1 | pw-cat --target streamer --playback --raw --rate 48000 --channels  2 --format s16 -
