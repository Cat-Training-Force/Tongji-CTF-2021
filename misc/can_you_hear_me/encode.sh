#!/bin/bash

python3 pic_flag.py && \
pysstv --mode Robot36 flag.png flag.wav && \
tar cf flag.tar flag.wav && \
clang dummy.c -o can_you_hear_me.exe && \
strip can_you_hear_me.exe && \
echo "Robot36, it's a little bit noisy here!" >> can_you_hear_me.exe && \
cat flag.tar >> can_you_hear_me.exe
