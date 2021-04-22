# Ping

## Description

I'm online!

## Deployment

### Setup DNS

Add a TXT record which contains 3 parts in one line:

- Base64 encoded "MD5": TUQ1
- A dot: .
- Base64 encoded key to retrieve the real flag

Example:
```
TUQ1.R2l2ZU1lRmxhZw==
```

for

```
MD5.GiveMeFlag
```

### Setup Docker

```bash
# Debian buster, run as root
apt update
apt upgrade
apt install docker
usermod -aG docker my_user
```

### Disable ICMP Echo

```bash
# Run as root
echo net.ipv4.icmp_echo_ignore_all=1 | tee /etc/sysctl.d/z01-disable_echo_reply.conf >/dev/null
sudo systemctl restart systemd-sysctl
```

### Run ping-responder

**Notice**:

- `eth0` should be replace by a dedicated network interface on the host
- `text in the request` should be replaced by MD5 hash of the key, for example, GiveMeFlag
- `text in the response` should be replaced by the real flag

```bash
# Run as my_user
git clone https://github.com/Cat-Training-Force/ping-responder
cd ping-responder
docker build -t ping-responder:latest .
docker run --read-only -d --restart always --net=host \
           -init --name ping-responder ping-responder:latest \
           ./ping-responder.py -i eth0 -t "text in the request" -s "text in the response"
```

## Get Flag

Example:

```bash
# Tested on Arch Linux
sudo nping -v4 --icmp --data-string $(echo -n "R2l2ZU1lRmxhZw==" | base64 -d | md5sum | sed 's/ .*$//') ctf.example.com -c 1
```
