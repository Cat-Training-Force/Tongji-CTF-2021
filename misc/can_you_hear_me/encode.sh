#!/bin/bash

python3 pic_flag.py && \
pysstv --mode Robot36 flag.png flag.wav && \
tar cf flag.tar flag.wav && \
clang dummy.c -o can_you_hear_me.exe && \
strip can_you_hear_me.exe && \
echo "Robot36, it's a little bit noisy here! Let's use AES-256-CBC" >> can_you_hear_me.exe && \
openssl enc -aes-256-cbc -in flag.tar -out flag.zip -pass pass:"Robot36" && \
cat flag.zip >> can_you_hear_me.exe
