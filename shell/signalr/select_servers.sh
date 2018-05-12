#!/bin/bash
. ./pre_servers_env.sh

function gen_servers_env() {
	local benchserver=$1
	local benchport=$2
	local benchuser=$3
	local serviceserver=$4
	local serviceport=$5
	local serviceuser=$6
	local appserver=$7
	local appport=$8
	local appuser=$9
	local serviceinternal=`ssh -p $serviceport ${serviceuser}@${serviceserver} "hostname -I"`
	local appinternal=`ssh -p $appport ${appuser}@${appserver} "hostname -I"`

cat << EOF > servers_env.sh
bench_server=$benchserver
bench_server_port=$benchport
bench_user=$benchuser

EOF
	if [ $use_internal_net -eq 1 ]
	then
cat << EOF >> servers_env.sh
bench_service_pub_server=$serviceserver
bench_service_pub_port=$serviceport
bench_service_server=$serviceinternal
bench_service_port=$service_port
bench_service_user=$serviceuser

bench_app_pub_server=$appserver
bench_app_pub_port=$appport
bench_app_server=$appinternal
bench_app_port=$server_port
bench_app_user=$appuser
EOF
	else
cat << EOF >> servers_env.sh
bench_service_pub_server=$serviceserver
bench_service_pub_port=$serviceport
bench_service_server=$serviceserver
bench_service_port=$service_port
bench_service_user=$serviceuser

bench_app_pub_server=$appserver
bench_app_pub_port=$appport
bench_app_server=$appserver
bench_app_port=$server_port
bench_app_user=$appuser
EOF
	fi
}

gen_servers_env $master1_host $master1_port $master1_user $slave1_host $slave1_port $slave1_user $slave2_host $slave2_port $slave2_user
