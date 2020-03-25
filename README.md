# vpp-tests
VPP tests

docker cp ./tests/http_simple.py trex-run:/opt/trex-core/scripts/astf/http_simple.py

VPP container installation:
1) requires only once for vpptool
  vpptool -debug install
2)
    vpptool -debug -docker-image vpp-tests -docker-tag latest setup
  or for specific commit id
    vpptool -debug -docker-image vpp-tests -docker-tag latest -commit <commit-id> setup
3)
  vpptool -debug -docker-image vpp-tests -docker-tag latest build
4)
  vpptool -debug deploy

- for updating/changing vpp commit id use steps 2,3,4
