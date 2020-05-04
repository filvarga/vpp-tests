#!/bin/bash

startup="startup.conf"
config="vpp.conf"

# TODO: make optional deployment

docker rm -f trex-run &> /dev/null
docker run -it -d --name trex-run \
  --privileged --cap-add=ALL --network=host \
  vpp-tests/trex:latest

#docker rm -f vpp-run &> /dev/null
# TODO: enable optional tag !! (master .. etc.)
# TODO: ofc don't forget vpptool -plugin !
#docker run -it -d --name vpp-run \
#  --privileged --cap-add=ALL --network=host \
#  vpp-tool/vpp:latest

# reconfigure trex
docker cp ./conf/trex/trex_cfg.yaml trex-run:/etc/trex_cfg.yaml

# reconfigure vpp
docker cp ./conf/vpp/$startup vpp-run:/etc/startup.conf
docker cp ./conf/vpp/$config vpp-run:/etc/vpp.conf
# restart vpp
docker exec -it vpp-run /scripts/kill
