# Can You Hear Me

## Description

OoOoOOO, it's a little bit noisy here.

## Setup

Read `encode.sh` and `clean.sh`

``` bash
# Python 3
pip install pillow pySSTV
```

## Usage

```bash
echo "ExampleFlag" > flag.txt
./encode.sh
./clean.sh
```

## Get Flag

```bash
binwalk -D=".*" can_you_hear_me.exe 
cd _can_you_hear_me.exe.extracted
openssl enc -d -aes-256-cbc -in 388F -out flag.tar # Password: Robot36
tar xf flag.tar
```

```bash
sudo apt install libsdl1.2-dev
git clone https://github.com/xdsopl/robot36
cd robot36
make
./decode flag.wav
```
