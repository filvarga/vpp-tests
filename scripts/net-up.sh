#!/bin/bash
# veth pair 1 (inside network)
ip link del dev vpp0 &> /dev/null
ip link add vpp0 type veth peer name vpp1
ip addr add 10.0.0.1/24 dev vpp0 &> /dev/null
ethtool -K vpp0 rx off tx off # ??
ip link set dev vpp0 up
# veth pair 2 (outside network)
ip link del dev vpp2 &> /dev/null
ip link add vpp2 type veth peer name vpp3
ip addr add 11.0.0.1/24 dev vpp2 &> /dev/null
ethtool -K vpp2 rx off tx off # ??
ip link set dev vpp2 up
