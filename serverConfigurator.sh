#!/bin/bash

vxlanIp=$1
vxlanId=$2
serviceName=$3
vmName=$4
portGroup=$5
ipAddress=$6
username=$7

ip netns | grep -o "[0-9]\+" | sort > tmp
i=1
while read line; do
  if [ "$line" != "$i" ]; then
    break
  else
    i=$(($i + 1))
  fi
done < tmp
rm tmp

ns=ns$i
veth=SS$i

if [ -f /home/vmB/srv-configs/services.list ]; then
  echo $serviceName $portGroup $vmName $ipAddress $vxlanIp $ns $username >> /home/vmB/srv-configs/services.list
else
  echo "Service Name Source Port Group Source Virtual Machine Name Source IP Address Destination IP Address Namespace Username" > /home/vmB/srv-configs/services.list
  echo $serviceName $portGroup $vmName $ipAddress $vxlanIp $ns $username >> /home/vmB/srv-configs/services.list
fi

ip netns add $ns
ip link add $vmName$serviceName type veth peer name $veth
ip link set $veth netns $ns
brctl addif bridge0 $vmName$serviceName
ip link set dev $vmName$serviceName up
ip netns exec $ns ip link set dev $veth name eth0
ip netns exec $ns ip link set dev eth0 up
ip netns exec $ns ip addr add 192.168.100.16/24 dev eth0
ip netns exec $ns ip link add vxlan type vxlan id $vxlanId group 239.0.0.1 port 0 0 ttl 4 dev eth0
ip netns exec $ns ip addr add $vxlanIp/24 dev vxlan
ip netns exec $ns ip link set dev vxlan up

#ip netns exec $ns ip link add link eth0 name eth0.$vlanId type vlan id $vlanId
#ip netns exec $ns ip link add link eth0 name eth0.$vlanId address aa:cc:dd:cc:bb:ee type macvlan
#ip netns exec $ns ip addr add $vlanIp/24 dev eth0.$vlanId
#ip netns exec $ns ip link set dev eth0.$vlanId up

iptables -P FORWARD ACCEPT
