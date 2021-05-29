#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Respond to ICMP pings with a custom payload.
#
# Copyright (c) 2019, Bright Pixel
#


import sys
import os
import logging
import logging.handlers
import pwd
import grp
import signal
import random

from argparse import ArgumentParser

# Don't let scapy pollute the output (must be set before importing)...
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
import scapy.config  # noqa: E402
from scapy.all import sniff, IP, ICMP  # noqa: E402


# Using the root logger directly is bad practice. All of our logging (including modules) should
# exist within the "myapp.*" namespace to avoid messing with logging inside third-party modules...
log = logging.getLogger("ping-responder")


# Default (unprivileged) credentials...
DEFAULT_USER = "nobody"

try:  # ...different distributions have different group names.
    DEFAULT_GROUP = "nobody"
    grp.getgrnam(DEFAULT_GROUP)
except KeyError:
    DEFAULT_GROUP = "nogroup"

# Some ping tools complain if they don't get the same payload length as they sent,
# so we pad our responses with zeroes, but we don't want to answer large requests...
MAX_ICMP_PAYLOAD_PADDING = 56  # ...the standard payload size on most clients.

# Maxiumum size we'll ever send in a response (it's better if it fits in a single packet)...
MAX_ICMP_PAYLOAD_SIZE = 1024  # ...1K should be enough for anyone.


def parse_args():
    """Parse and enforce command-line arguments."""

    # Disable the automatic "-h/--help" argument to customize its message...
    parser = ArgumentParser(add_help=False, description="Respond to ICMP echo-request packets with a custom payload.",
                                            epilog="The system will also respond to ICMP echo-requests by default. "
                                                   "To disable it, run \"sysctl -w net.ipv4.icmp_echo_ignore_all=1\" "
                                                   "as root.")

    parser.add_argument("-h", "--help", action="help",
                              help="Show the available options and exit.")
    parser.add_argument("-v", dest="verbose", action="store_true",
                              help="Produce extra output for debugging purposes.")
    parser.add_argument("-l", dest="log", action="store", metavar="filename",
                              help="Send log messages into the specified file.")

    parser.add_argument("-u", dest="user", action="store", metavar="user", default=DEFAULT_USER,
                              help="Run using this as this user. [default: %s]" % DEFAULT_USER)
    parser.add_argument("-g", dest="group", action="store", metavar="group", default=DEFAULT_GROUP,
                              help="Run using this group's credentials. [default: %s]" % DEFAULT_GROUP)
    parser.add_argument("-i", dest="iface", action="store", metavar="iface",
                              help="Listen on this network interface. [default: %s]" % scapy.config.conf.iface)

    parser.add_argument("-t", dest="trigger", action="store", metavar="text",
                              help="Reply only to ICMP echo-requests containing this text.")

    parser.add_argument("-z", dest="fuzzy", action="store_true",
                              help="Fuzzy match the trigger text.")
    parser.add_argument("-r", dest="randomize", action="store_true",
                              help="Reply with a single random line from the response text.")

    group = parser.add_mutually_exclusive_group()

    group.add_argument("-s", dest="text", action="store", metavar="text",
                             help="Text to send back in ICMP echo-response packets.")
    group.add_argument("-f", dest="filename", action="store", metavar="filename",
                             help="File to send back in ICMP echo-response packets.")

    return parser.parse_args()


def signal_handler(signum, frame):
    """Terminate the process cleanly."""

    os._exit(0)


def drop_privileges(user, group):
    """Drop all privileges and run as the specified user and group."""

    uid = pwd.getpwnam(user)[2] if not user.isdigit() else user
    gid = grp.getgrnam(group)[2] if not group.isdigit() else group

    logging.debug("Dropping root privileges: uid:%d(%s), gid:%d(%s).", uid, user, gid, group)

    # Drop "root" and set a restrictive umask...
    os.setgid(gid)
    os.setuid(uid)
    os.umask(0o077)


def send_icmp_echo_reply(raw_socket, gw, request_packet, payload_bytes=None, trigger_bytes=None, fuzzy_match=False):
    """
    Send an ICMP echo-reply containing the specified payload back to the sender.
    When a trigger is specified, only requests that include it will be answered.
    """

    if not request_packet.haslayer(IP) or not request_packet.haslayer(ICMP) or request_packet[IP][ICMP].type != 8:
        raise ValueError("request is not an ICMP echo-request packet")

    req_ip = request_packet[IP]
    req_icmp = request_packet[IP][ICMP]

    # Make it easier for the code below...
    request_load = request_packet.load if hasattr(request_packet, "load") else b""

    if log.isEnabledFor(logging.DEBUG):  # ...show part of the received payload (printable ASCII range).
        snippet = "".join(chr(b) if 32 <= b <= 126 else "." for b in request_load[:MAX_ICMP_PAYLOAD_PADDING])

        if len(request_load) > len(snippet):
            log.debug("Request %d/%d payload (first %d bytes): '%s'", req_icmp.id, req_icmp.seq, len(snippet), snippet)
        else:
            log.debug("Request %d/%d payload: '%s'", req_icmp.id, req_icmp.seq, snippet)

    if trigger_bytes is not None:
        match_request = request_load
        match_trigger = trigger_bytes

        if fuzzy_match:  # ...normalize both sides before comparison.
            match_request = match_request.replace(b" ", b"").lower()
            match_trigger = match_trigger.replace(b" ", b"").lower()

        if match_request != match_trigger:
            log.debug("Ignoring ICMP echo-request from %s without trigger payload." % req_ip.src)
            return

    log.info("ICMP echo-request from %s [id=%d,seq=%d,len=%d]" % (req_ip.src, req_icmp.id, req_icmp.seq, len(req_icmp)))

    if not payload_bytes:
        payload_bytes = request_load

    # If there are multiple possible response payloads, choose one...
    if payload_bytes and type(payload_bytes[0]) in (bytes, str):
        payload_bytes = random.choice(payload_bytes)

        if isinstance(payload_bytes, str):
            # Strings were included in the check above to avoid confusing errors, nothing more...
            raise TypeError("response payloads must be byte sequences, not strings")

    payload_length = len(payload_bytes)
    max_payload_length = min(len(request_load), MAX_ICMP_PAYLOAD_PADDING)

    if payload_length < max_payload_length:  # ...add padding.
        payload_bytes += b"\0" * (max_payload_length - payload_length)

    # Replies may be dropped if the destination MAC address cannot be resolved
    # due to lack of privileges (it will default to the broadcast MAC address).
    # To work around this, we ensure it's always pre-cached before sending...
    scapy.config.conf.netcache.arp_cache[gw["ip"]] = gw["mac"]

    rep_ip = IP(src=req_ip.dst, dst=req_ip.src, id=random.getrandbits(16))
    rep_icmp = ICMP(type=0, id=req_icmp.id, seq=req_icmp.seq)
    raw_socket.send(rep_ip / rep_icmp / payload_bytes)

    log.info("ICMP echo-reply to %s [id=%d,seq=%d,len=%d]", rep_ip.dst, rep_icmp.id, rep_icmp.seq, len(rep_icmp))


def main():
    args = parse_args()

    if os.getuid() != 0:
        print("This program requires RAW sockets and must be started as \"root\".", file=sys.stderr)
        sys.exit(1)

    # Formatting and pointing all messages to standard error (or a file) at the root logger level
    # ensures everything gets a timestamp and doesn't get lost in some console that nobody reads...
    format = logging.Formatter("%(asctime)s: %(levelname)s: %(message)s")
    handler = logging.handlers.WatchedFileHandler(args.log) if args.log else logging.StreamHandler(sys.stderr)
    handler.setFormatter(format)
    logging.getLogger().addHandler(handler)

    # Leaving the root logger with the default level, and setting it in our own logging hierarchy
    # instead, prevents accidental triggering of third-party logging, just like $DEITY intended...
    log.setLevel(logging.DEBUG if args.verbose else logging.INFO)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGQUIT, signal_handler)

    trigger = args.trigger.encode("utf-8") if args.trigger else None

    if args.text:  # ...text and file arguments are mutually exclusive.
        payload = args.text.encode("utf-8")
    elif args.filename:
        try:
            with open(args.filename, "rb") as f:
                payload = f.read()
        except OSError as e:
            log.error(str(e))
            sys.exit(1)
    else:
        payload = None  # ...just echo back what the requestor sent.

    if payload:
        # We don't modify the response payloads, not even to filter out blank/empty lines...
        payload = payload.replace(b"\r\n", b"\n").split(b"\n") if args.randomize else [payload]

        if any(len(p) > MAX_ICMP_PAYLOAD_SIZE for p in payload):
            log.error("Custom ICMP payload(s) must not exceed %d bytes!", MAX_ICMP_PAYLOAD_SIZE)
            sys.exit(1)

    # Be quiet and don't use promiscuous mode, ever...
    scapy.config.conf.verb = 0
    scapy.config.conf.promisc = False
    scapy.config.conf.sniff_promisc = False

    if args.iface:  # ...use this network interface instead of the default.
        scapy.config.conf.iface = args.iface

    # Resolving the default route's MAC address after dropping privileges isn't allowed,
    # preventing ICMP replies from reaching their destination. Of course, obtaining it once
    # at startup assumes it won't ever change while we're running. We'll be fine, though...
    gw_ip = scapy.config.conf.route.route("0.0.0.0")[2]
    gw_mac = scapy.layers.l2.getmacbyip(gw_ip)
    gw = {"ip": gw_ip, "mac": gw_mac}

    # We need to create the sending socket before dropping root privileges...
    raw_socket = scapy.config.conf.L3socket(iface=scapy.config.conf.iface)
    capture_cb = lambda packet: send_icmp_echo_reply(raw_socket, gw, packet, payload, trigger, fuzzy_match=args.fuzzy)
    started_cb = lambda: drop_privileges(args.user, args.group)

    log.info("Starting capture on %s...", scapy.config.conf.iface)

    # Using a BPF filter reduces CPU usage considerably but needs elevated
    # privileges (because scapy uses "tcpdump" for filtering). These privileges
    # must be dropped immediately after capture has started for better security...
    sniff(filter="icmp and icmp[icmptype] == 8", prn=capture_cb, started_callback=started_cb, store=0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass


# vim: set expandtab ts=4 sw=4:
