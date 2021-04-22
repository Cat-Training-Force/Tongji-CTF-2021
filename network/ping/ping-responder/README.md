# Keyword-based ICMP ping responder

This service allows your machine to ignore ICMP `echo-request` packets (pings) unless the remote client includes a specific keyword (and only that keyword) as the payload, at which point it will send back an ICMP `echo-reply` containing some custom data.

This was written for one of the challenges in the Pixels Camp [quizshow](https://blog.pixels.camp/the-quizshow-wrap-up-58a4855be6c) qualifiers, so it may or may not prove useful in other situations.

## Usage

The `ping-responder.py` script can be run directly on the machine, or it can be run inside a container. In any case the host must be prevented from sending ICMP `echo-reply` packets. On Linux this means changing a kernel tunable, like so (in CentOS 7.x):
```
$ echo net.ipv4.icmp_echo_ignore_all=1 | sudo tee /etc/sysctl.d/z01-disable_echo_reply.conf >/dev/null
$ sudo systemctl restart systemd-sysctl
```

Now, to run the service inside a container (the recommended way, for a bit of extra safety):
```
$ sudo docker build -t ping-responder:latest .
$ sudo docker run --read-only -d --restart always --net=host \
                  --init --name ping-responder ping-responder:latest \
                  ./ping-responder.py -i eth0 -t "text in the request" -s "text in the response"
```

Replace `eth0` by the network interface you want to use **on the host** and note that `--net=host` is required otherwise it would only respond to pings sent from within the container network.

## Deployment

On November 1st, 2020, we modified this service for a [small homage](https://twitter.com/pixelscamp/status/1322848356616478721) to [Sean Connery](https://en.wikipedia.org/wiki/Sean_Connery) — who had just died on October 31st — as the challenge mentioned above involved one of his films. This was deployed into a standalone VM using a `Makefile` and tested with an Ubuntu VM bootstrapped with [Vagrant](https://www.vagrantup.com/). You can find both of these things at the root of the repository as a deployment example.
