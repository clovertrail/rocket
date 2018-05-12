#!/bin/bash
. ./env.sh

function copy_and_unzip_package() {
	local pkg=$1

	scp -P $bench_server_port ${pkg}.tgz ${bench_user}@${bench_server}:~/
	ssh -p $bench_server_port ${bench_user}@${bench_server} "[ -d ${pkg} ] && rm -rf ${pkg}"
	ssh -p $bench_server_port ${bench_user}@${bench_server} "tar zxvf ${pkg}.tgz"

	scp -P $bench_service_pub_port ${pkg}.tgz ${bench_service_user}@${bench_service_pub_server}:~/
	ssh -p $bench_service_pub_port ${bench_service_user}@${bench_service_pub_server} "[ -d ${pkg} ] && rm -rf ${pkg}"
	ssh -p $bench_service_pub_port ${bench_service_user}@${bench_service_pub_server} "tar zxvf ${pkg}.tgz"

	scp -P $bench_app_pub_port ${pkg}.tgz ${bench_app_user}@${bench_app_pub_server}:~/
	ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "[ -d ${pkg} ] && rm -rf ${pkg}"
	ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "tar zxvf ${pkg}.tgz"
}

function copy_and_unzip() {
	local dist_dir=$1
	cd $dist_dir	
	if [ -e ${signalr_core_package}.tgz ]
	then
		copy_and_unzip_package ${signalr_core_package}
	fi

	if [ -e ${signalr_service_package}.tgz ]
	then
		copy_and_unzip_package ${signalr_service_package}
	fi

	if [ -e ${signalr_bench_demo}.tgz ]
	then
		copy_and_unzip_package ${signalr_bench_demo}
	fi

	cd -
}

copy_and_unzip $signalr_build_dist
