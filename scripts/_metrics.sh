docker exec -it vpp-run vppctl show errors
docker exec -it vpp-run vppctl show nat44 summary
#docker exec -it vpp-run vppctl show nat44 addresses
#docker exec -it vpp-run ./build-root/install-vpp_debug-native/vpp/bin/vpp_get_stats dump "/nat44/total-sessions"
