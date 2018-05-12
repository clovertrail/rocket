#!/bin/bash
. ./env.sh

function render_service_appsettings() {
	local output_dir=$1
	export ServiceEndpoint=${bench_service_server}:${bench_service_port}
	python $sigbench_render_script -t appsetings/signalrservice_appsettings.json > $output_dir/appsettings.json
}

function render_signalrcore_appsettings() {
	local output_dir=$1
	export BroadcastThreshold=`expr $bench_config_duration \* $bench_config_concurrent_users`
	python $sigbench_render_script -t appsetings/signalrcoreapp_appsettings.json > $output_dir/appsettings.json
}

function render_signalrservicedemo_appsettings() {
	local output_dir=$1
	export ServiceEndpoint=${bench_service_server}:${bench_service_port}
	export BroadcastThreshold=`expr $bench_config_duration \* $bench_config_concurrent_users`
	python $sigbench_render_script -t appsetings/signalrservicedemo_appsettings.json > $output_dir/appsettings.json
}

function zip_signalr_package() {
	cd $signalr_build_dist
	if [ -d $signalr_core_package ]
	then
		tar zcvf ${signalr_core_package}.tgz $signalr_core_package
	fi

	if [ -d $signalr_service_package ]
	then
		tar zcvf ${signalr_service_package}.tgz $signalr_service_package
	fi

	if [ -d $signalr_bench_demo ]
	then
		tar zcvf ${signalr_bench_demo}.tgz $signalr_bench_demo
	fi

	cd -
}

render_service_appsettings `pwd`/$signalr_build_dist/$signalr_service_package
render_signalrcore_appsettings `pwd`/$signalr_build_dist/$signalr_core_package
render_signalrservicedemo_appsettings `pwd`/$signalr_build_dist/$signalr_bench_demo
zip_signalr_package
