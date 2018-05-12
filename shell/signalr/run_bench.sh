#!/bin/bash
. ./env.sh

function start_sigbench
{
	local startbench=$bench_start_file
	scp -P $bench_server_port $startbench $bench_user@${bench_server}:~/$sigbench_home
	ssh -p $bench_server_port $bench_user@${bench_server} "cd $sigbench_home; chmod +x ./$startbench"
	ssh -p $bench_server_port $bench_user@${bench_server} "cd $sigbench_home; ./$startbench"
}

function stop_sigbench
{
	local stopbench=$bench_stop_file
	scp -P $bench_server_port $stopbench $bench_user@${bench_server}:~/
	ssh -p $bench_server_port $bench_user@${bench_server} "chmod +x ./$stopbench"
	ssh -p $bench_server_port $bench_user@${bench_server} "./$stopbench"
}

function gen_sigbench_config
{
cat << _EOF > $sigbench_env_file
#!/bin/bash
# automatic generated script

config_file=$sigbench_config_file
output_dir=$sigbench_output_dir
agent_output=$sigbench_agent_output
pidfile=$sigbench_pid_file
_EOF
	scp -P $bench_server_port $sigbench_env_file $bench_user@${bench_server}:~/$sigbench_home
}

function select_sigbench_config
{
	export UsersPerSecond=$bench_config_concurrent_users
	export Duration=$bench_config_duration
	export Endpoint=$bench_config_endpoint
	export Hub=$bench_config_hub
	export Key=$bench_config_key
	python $sigbench_render_script -t $sigbench_config_dir/config_${bench_name}_${bench_type}_${bench_codec}.yaml > $result_dir/$sigbench_config_file
}

function launch_sigbench_master
{
	local remote_run="autogen_runbench.sh"
	select_sigbench_config
	scp -P $bench_server_port $result_dir/$sigbench_config_file $bench_user@${bench_server}:~/$sigbench_home
	scp -P $bench_server_port $sigbench_master_starter $bench_user@${bench_server}:~/$sigbench_home
cat << _EOF > $remote_run
#!/bin/bash
# automatic generated script
ssh -p $bench_server_port $bench_user@${bench_server} "cd $sigbench_home; sh $sigbench_master_starter"
_EOF
	nohup sh $remote_run > ${result_dir}/$sigbench_log_file 2>&1 &
}

function check_and_wait
{
	local fail
	local end=$((SECONDS + $sigbench_run_duration))
	while [ $SECONDS -lt $end ]
	do
		sleep 1
		scp -P $bench_server_port $bench_user@${bench_server}:~/$sigbench_home/$sigbench_agent_output ${result_dir}/ > /dev/null 2>&1
		fail=`grep -i "fail" ${result_dir}/$sigbench_agent_output`
		if [ "$fail" != "" ]
		then
			echo "Error occurs, so break the benchmark, please check ${result_dir}/$sigbench_agent_output"
			break
		fi
	done
}

function fetch_result
{
	scp -P $bench_server_port -r $bench_user@${bench_server}:~/$sigbench_home/$sigbench_output_dir ${result_dir}/
}

function prepare
{
	mkdir -p $result_dir
}

prepare

gen_sigbench_config

start_sigbench

launch_sigbench_master

check_and_wait

stop_sigbench

fetch_result
