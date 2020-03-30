./pci_config.py vpp $vpp_slot0 $vpp_slot1 > startup.conf
./pci_config.py trex $trx_slot0 $trex_slot1 > trex_cfg.yaml

# trex container configuration for dpdk (required??)
sudo docker run -it --name $3 \
  --privileged --cap-add=all -d \
  --network host \
  -v /sys/devices/system/node:/sys/devices/system/node \
  -v /sys/bus/pci/devices:/sys/bus/pci/devices \
  -v /dev/hugepages:/dev/hugepages \
  $1:$2

get_mac ()
{
  ip link show $1 | grep link/ether | awk '{print $2}'
}

sudo modprobe vfio-pci

vpp_iface0=`./scripts/config.py slot-to-name $pci_slot0`
vpp_iface1=`./scripts/config.py slot-to-name $pci_slot1`

# be sure the interfaces are down before starting vpp
sudo ip link set dev $vpp_iface0 down &> /dev/null
sudo ip link set dev $vpp_iface1 down &> /dev/null

trx_iface0=`./scripts/config.py slot-to-name $pci_slot2`
trx_iface1=`./scripts/config.py slot-to-name $pci_slot3`

# be sure trex interfaces are up before starting trex
sudo ip link set dev $trx_iface0 up &> /dev/null
sudo ip link set dev $trx_iface1 up &> /dev/null
