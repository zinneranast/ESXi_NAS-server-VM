#!/bin/bash

ifconfig eth0 0
brctl addbr bridge0
ip link set dev bridge0 up
brctl addif bridge0 eth0
ip link set dev eth0 up

echo 1 > /proc/sys/net/ipv4/conf/all/accept_source_route
