#!/bin/bash

warm_up=0
threads=1
#threads=2
#threads=4

startup="startup.conf"
config="vpp.conf"

# TODO: test as argument ?
#test="http_simple.py"
test="http_advanced.py"

# rate-multipleier != cps (if custom.py not used)
usage ()
{
  printf "$0 usage: <duration> <rate-multiplier>\n"
  exit 1
}

if [ "$#" -ne 2 ]; then
  usage
fi

d=$1
m=$2

# reconfigure trex
docker cp ./conf/trex/trex_cfg.yaml trex-run:/etc/trex_cfg.yaml

# reconfigure vpp && restart in container vpp (faster)
docker cp ./conf/vpp/$startup vpp-run:/etc/startup.conf
docker cp ./conf/vpp/$config vpp-run:/etc/vpp.conf

# TODO: make optional to reconfigure
# some tests may require running multiple times on same vpp
# without restarting it
docker exec -it vpp-run /scripts/kill

# -d Duration of test in sec (default is 3600).
# -m Rate multiplier. Multiply basic rate of templates by this number.
# cps - connections per second (v astf/yaml) - multiplier multiplies cps by m
# cps * m = (number of coonections)
# -c Number of hardware threads to allocate for each port pair.
# -k Run 'warm up' traffic for num before starting the test.
# cache reuse before sending packets (sends packets during cache but doesn't measure)
#  - if we need exact metrics we can't use this !!
# --astf  Enable advanced stateful mode. (profile should be in py format)

sleep 2
read  -n 1 -p "Hit key..."
./scripts/t-rex-64 -f astf/$test -d $d -m $m -c $threads \
  --astf -k $warm_up --cfg /etc/trex_cfg.yaml
