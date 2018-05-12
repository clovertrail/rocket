#!/bin/bash
. ./env.sh

function stop_signalr() {
	ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "killall ${signalr_service_app_name}"
	ssh -p $bench_service_pub_port ${bench_service_user}@${bench_service_pub_server} "killall ${signalr_service_name}"
	ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "killall ${signalr_core_app_name}"
}

stop_signalr
