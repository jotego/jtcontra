#!/bin/bash
mv video video2
rm -rf video2&
mkdir -p video
convert -size 280x240 -depth 8 RGBA:video.raw video/video.jpg
cd video
rmdup.sh