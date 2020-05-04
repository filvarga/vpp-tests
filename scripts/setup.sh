#!/bin/bash

docker rm -f trex-run &> /dev/null
docker run -it -d --name trex-run \
  --privileged --cap-add=ALL --network=host \
  vpp-tests/trex:latest

#docker rm -f vpp-run &> /dev/null
# TODO: (change your docker run command for creating vpp container)
#docker run -it -d --name vpp-run \
#  --privileged --cap-add=ALL --network=host \
#  vpp-tests/vpp:latest
