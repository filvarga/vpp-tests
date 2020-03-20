# veth pair 1 (inside network)
sudo ip link del dev vpp0 &> /dev/null
sudo ip link add vpp0 type veth peer name vpp1 &> /dev/null
sudo ip addr add 10.0.0.1/24 dev vpp0 &> /dev/null
sudo ethtool -K vpp0 rx off tx off # ??
sudo ip link set dev vpp0 up
# veth pair 2 (outside network)
sudo ip link del dev vpp2 &> /dev/null
sudo ip link add vpp2 type veth peer name vpp3 &> /dev/null
sudo ip addr add 11.0.0.1/24 dev vpp2 &> /dev/null
sudo ethtool -K vpp2 rx off tx off # ??
sudo ip link set dev vpp2 up
