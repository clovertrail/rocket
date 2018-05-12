#!/bin/bash
. ./env.sh

function build_signalrservice() {
	local output_dir=$1
	cd $signalr_src_root/src/SignalRServer/src/Microsoft.Azure.SignalR.Server
	dotnet publish -c Release -f netcoreapp2.0 -o $output_dir/$signalr_service_package --self-contained  -r linux-x64
	cd -
}

function build_signalrcore() {
	local output_dir=$1
	cd $signalr_src_root/samples/Latency/
	dotnet publish -c Release -f netcoreapp2.0 -o $output_dir/$signalr_core_package --self-contained  -r linux-x64
	cd -
}

function build_signalrdemo() {
	local output_dir=$1
	cd $signalr_sdk_src_root/samples/ChatBench
	dotnet publish -c Release -f netcoreapp2.0 -o $output_dir/$signalr_bench_demo --self-contained  -r linux-x64
	cd -
}

if [ -e $signalr_build_dist ]
then
	rm -rf $signalr_build_dist
fi
mkdir $signalr_build_dist

build_signalrservice `pwd`/$signalr_build_dist
build_signalrcore `pwd`/$signalr_build_dist
build_signalrdemo `pwd`/$signalr_build_dist
