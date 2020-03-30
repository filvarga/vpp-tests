#!/usr/bin/env python

from sys import stderr
from subprocess import Popen, PIPE
from os import walk, listdir
from os.path import join
from argparse import ArgumentParser

def check_output(args, stderr=None):
    return Popen(args, stdout=PIPE, stderr=stderr).communicate()[0]


class Device(object):

    def __init__(self, slot, link):
        self.link = link
        self.slot = slot

    def unbind(self):
        filename = "/sys/bus/pci/devices/{}/driver/unbind".format(self.slot)
        try:
            with open(filename, "a") as fo:
                fo.write(self.slot)
        except:
            stderr.write("error unbinding {}".format(self))

    def bind(self, driver):
        filename = "/sys/bus/pci/drivers/{}/bind".format(driver)
        try:
            with open(filename, "a") as fo:
                fo.write(self.slot)
        except:
            stderr.write("error binding {}".format(self))


class Devices(dict):

    def filter_by_slots(self, slots):
        return map(self.get, slots)


def get_all():
    devices = Devices()

    dev = dict()
    dev_lines = check_output(["lspci", "-Dvmmnnk"]).splitlines()
    for dev_line in dev_lines:

        # check if type matches ?
        if len(dev_line):
            name, value = dev_line.decode().split("\t", 1)

            value_list = value.rsplit(' ', 1)
            if len(value_list) > 1:
                value = value_list[-1].rstrip("]").lstrip("[")

            dev[name.rstrip(":")] = value
            continue

        tmp = dev
        dev = dict()

        if tmp['Class'][0:2] != '02':
            continue

        for base, dirs, _ in walk("/sys/bus/pci/devices/{}/".format(tmp['Slot'])):
            if "net" in dirs:
                tmp['Interface'] = ",".join(listdir(join(base, "net")))
                break

        # store the device
        devices[tmp['Slot']]= Device(tmp['Slot'], dev.get('Interface'))
    return devices


def create_vpp_config(args, devs):
    dev0, dev1 = devs.filter_by_slots((args.slot0, args.slot1)) 
    config = """
unix {{
  interactive
  full-coredump
}}

api-trace {{ on }}

nat {{ endpoint-dependent }}

dpdk {{
  dev {0} {{ name lan0 }}
  dev {1} {{ name lan1 }}
}}
    """
    print(config.format(dev0.slot, dev1.slot))


def create_trex_config(args):
    dev0, dev1 = devs.filter_by_slots((args.slot0, args.slot1))
    config = """
- port_limit: 2
  version: 2
  interfaces: ["{0}", "{1}"]
  
  port_info:
    - ip         : 10.0.0.1
      default_gw : 10.0.0.2
      src_mac    : 00:00:00:02:00:00
      dst_mac    : 00:00:00:03:00:00
    - ip         : 11.0.0.1
      default_gw : 11.0.0.2
      src_mac    : 00:00:00:04:00:00
      dst_mac    : 00:00:00:05:00:00

  c: 4
  platform:
    master_thread_id: 0
    latency_thread_id: 8
    dual_if:
      - socket: 0
        threads: [1,2,3,4,5,6,7]
      - socket: 1
        threads: [9,10,11,12,13,14,15]
    """
    print(config.format(dev0.link, dev1.link))

def rebind_devices(args, devs):
    for dev in devs.filter_by_slots(args.slots):
        dev.unbind()
        dev.bind(args.driver)

def print_devices(args, devs):
    for dev in devs.values():
        print("slot: {0} link: {1}".format(
            dev.slot, dev.link if dev.link else ''))

def slot_to_name(args, devs):
    dev = devs.filter_by_slots([args.slot])
    if dev:
        print(dev.link)

def get_args():
    parser = ArgumentParser()
    sps = parser.add_subparsers()

    # create vpp / trex configuration file
    ps = [sps.add_parser('vpp'), sps.add_parser('trex')]
    ps[0].set_defaults(clb=create_vpp_config)
    ps[1].set_defaults(clb=create_trex_config)

    for p in ps:
        p.add_argument('slot0', help='pci slot')
        p.add_argument('slot1', help='pci slot')

    # rebind
    p = sps.add_parser('rebind')
    p.set_defaults(clb=rebind_devices)

    p.add_argument('driver', help='driver to rebind to')
    p.add_argument('slots', metavar='N', type=str, nargs='+',
                   help='pci slots')

    # slot-to-name
    p = sps.add_parser('slot-to-name')
    p.set_defaults(clb=slot_to_name)

    p.add_argument('slot', help='pci slot')

    # list command
    p = sps.add_parser('print')
    p.set_defaults(clb=print_devices)

    return parser.parse_args()

def main():
    args = get_args()
    devs = get_all()

    args.clb(args, devs)

if __name__ == '__main__':
    main()
