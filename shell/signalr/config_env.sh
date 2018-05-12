#!/bin/bash
. ./servers_env.sh

## set the SignalR bench configuration ##
bench_name_list="echo broadcast"
bench_type_list="selfhost service"
bench_codec_list="json msgpack"
#bench_name="echo"      # broadcast, echo
#bench_type="selfhost"  # selfhost, service
#bench_codec="json"     # json, msg
#bench_broadcast_threshold=12000
#bench_config_concurrent_users=100
#bench_config_duration=40
build_signalr=0  #1 means rebuild, 0 means no build
generate_appsettings=1 #1 means generate appsettings, 0 means no generate appsettings
deploy_signalr=1 #1 means deploy, 0 means no deploy
if [ "$bench_type" == "service" ]
then
	bench_config_endpoint=${bench_service_server}:${bench_service_port}
else
	bench_config_endpoint=${bench_app_server}:${bench_app_port}
fi
bench_config_hub="chat"
bench_config_key="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

sigbench_run_duration=360 #second running for benchmark
