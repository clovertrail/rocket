#!/bin/bash
. ./env.sh

function check_server() {
	local server=$1
	local port=$2
	local user=$3
	local dir=$4
	local i=0
	local ok=0
	while [ $i -lt 60 ]
	do
		scp -P $port ${user}@${server}:~/${dir}/out.log .
		local started=`grep "Application started" out.log`
		local exception=`grep "Exception" out.log`
		local fail=`grep -i "fail" out.log`
		if [ "$exception" != "" ] || [ "$fail" != "" ]
		then
			echo "Fail to run $dir"
			exit 1
		fi

		if [ "$started" != "" ] && [ "$exception" == "" ] && [ "$fail" == "" ]
		then
			ok=`expr $ok + 1`
		fi
		if [ $ok == 3 ]
		then
			break
		fi
		sleep 1
		i=`expr $i + 1`
	done
}

function start_signalr() {
	local service_script="autogen_launch_signalr_service.sh"
	local app_server_script="autogen_launch_signalr_app.sh"
	local core_app_script="autogen_launch_signalr_core.sh"

cat << EOF > $service_script
#!/bin/bash
# automatic generated script
if [ -d ${signalr_service_package} ]
then
	cd ${signalr_service_package}
	nohup ./${signalr_service_name} > out.log 2>&1 &
fi
EOF

cat << EOF > $app_server_script
#!/bin/bash
# automatic generated script
if [ -d ${signalr_bench_demo} ]
then
	cd ${signalr_bench_demo}
	nohup ./${signalr_service_app_name} > out.log 2>&1 &
fi
EOF

cat << EOF > $core_app_script
#!/bin/bash
# automatic generated script
if [ -d ${signalr_core_package} ]
then
	cd ${signalr_core_package}
	nohup ./${signalr_core_app_name} > out.log 2>&1 &
fi
EOF
	if [ $bench_type == "service" ]
	then
		# stop
		ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "killall ${signalr_service_app_name}"
		ssh -p $bench_service_pub_port ${bench_service_user}@${bench_service_pub_server} "killall ${signalr_service_name}"
		# start service
		scp -P $bench_service_pub_port $service_script ${bench_service_user}@${bench_service_pub_server}:~/
		ssh -p $bench_service_pub_port ${bench_service_user}@${bench_service_pub_server} "sh $service_script"
		# check whether service run successfully
		check_server ${bench_service_pub_server} $bench_service_pub_port ${bench_service_user} ${signalr_service_package}
		# start app
		scp -P $bench_app_pub_port $app_server_script ${bench_app_user}@${bench_app_pub_server}:~/
		ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "sh $app_server_script"
		# check whether app run successfully
		check_server ${bench_app_pub_server} $bench_app_pub_port ${bench_app_user} ${signalr_bench_demo}
	else
		# stop
		ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "killall ${signalr_core_app_name}"
		# start app
		scp -P $bench_app_pub_port $core_app_script ${bench_app_user}@${bench_app_pub_server}:~/
		ssh -p $bench_app_pub_port ${bench_app_user}@${bench_app_pub_server} "sh $core_app_script"
		# check whether app run successfully
		check_server ${bench_app_pub_server} $bench_app_pub_port ${bench_app_user} ${signalr_core_package}
	fi
}

start_signalr
exit 0
