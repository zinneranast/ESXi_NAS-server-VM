#!/bin/bash

serviceName=$1
username=$2

if [ "$username" = "root" ]; then
  grep $serviceName /home/vmB/srv-configs/services.list
else
  grep "$serviceName.*$username" /home/vmB/srv-configs/services.list
fi

