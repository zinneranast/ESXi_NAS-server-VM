#!/bin/bash

serviceName=$1
vmName=$2
username=$3

if [ $# -eq 0 ]; then
  ip netns > tmp
  while read line; do
    ip netns del $line  
  done < tmp
  rm tmp
  rm services.list
else
  ns=`grep "^$serviceName.*$vmName" /home/vmB/srv-configs/services.list | awk '{print $6}'`
  ip netns del $ns
  ip link del $vmName$serviceName
  sed -e "/^$serviceName.*$vmName.*$username/d" /home/vmB/srv-configs/services.list > tmp
  cp tmp /home/vmB/srv-configs/services.list
  rm tmp
fi
