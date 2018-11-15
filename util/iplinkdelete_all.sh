#!/bin/sh
sudo ip link show type veth|cut -d" " -f2|cut -d":" -f1|cut -d"@" -f1 |grep 0x | sudo xargs -L 1 -t ip link delete
sudo rm /tmp/vhost.h*
