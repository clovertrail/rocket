#!/bin/sh
. env.sh

gen_kick() {
  local conn=$1
  local output=$2
cat << EOF > $KICK_SCRIPT
#!/bin/bash
dst=${SERVER_URL}
th=\$(nproc)
dur=${DUR}
#dst=http://wcn.chinanorth.cloudapp.chinacloudapi.cn/app.txt
logger -t "WRK_LOG" "./wrk -c $conn -t \$th -d \$dur --latency --timeout $TIMEOUT --connreqs 1 \$dst > $output"
./wrk -c $conn -t \$th -d \$dur --latency --timeout $TIMEOUT --connreqs 1 \$dst > $output 
EOF
}

log() {
  local tag="WRKPERF"
  local msg="$1"
  logger -t $tag "$msg"
}

test_gen() {
  for i in $CONN_LIST
  do
    outf=${i}-${DUR}-wrkout.txt
    gen_kick $i $outf
    log "gen_kick $i $outf"
  done
}

stop_netstat() {
    # stop the netstat by force because some of the processes may not stop
    ssh $USER@${SERVER} killall ./netstat.sh
    ssh $USER@${SERVER} killall ./netstat.sh
    ssh $USER@${SERVER} killall ./netstat.sh
    log "ssh $USER@${SERVER} killall ./netstat.sh"
    ssh $USER@${SERVER} killall netstat
    ssh $USER@${SERVER} killall netstat
    ssh $USER@${SERVER} killall netstat
    log "ssh $USER@${SERVER} killall netstat"
}

run_test() {
  local prefix=$1
  local outf
  local localout
  local client
  local sleep_dur=`expr $DUR_SE + 30`
  mkdir ${prefix} # generate output folder
  for i in $CONN_LIST
  do
    outf=${i}-${DUR}-wrkout.txt
    gen_kick $i $outf
    log "gen_kick $i $outf"
    # launch all clients
    for j in $CLIENT_LIST
    do
       client=${j}${VM_POSTFIX}
       scp $KICK_SCRIPT $USER@${client}:~/
       log "scp $KICK_SCRIPT $USER@${client}:~/"
       ssh $USER@${client} nohup ./$KICK_SCRIPT &
       log "ssh $USER@${client} nohup ./$KICK_SCRIPT &"
    done
    # launch server netstat monitor
    stop_netstat
    scp netstat.sh $USER@${SERVER}:~/
    log "scp netstat.sh $USER@${SERVER}:~/"
    ssh $USER@${SERVER} nohup ./netstat.sh ${DUR_SE} &
    log "ssh $USER@${SERVER} nohup ./netstat.sh ${DUR_SE} &"
    # launch client access simulation for max latency check
    scp client_simu.sh $USER@${client}:~/
    log "scp client_simu.sh $USER@${client}:~/"
    ssh $USER@${client} nohup ./client_simu.sh $i $DUR_SE ${SERVER_URL} ${CLIENT_SIMU_OUTPOST} &
    log "ssh $USER@${client} nohup ./client_simu.sh $i $DUR_SE ${SERVER_URL} ${CLIENT_SIMU_OUTPOST} &"
    # wait all clients finished
    sleep $sleep_dur
    # collect results from clinets
    scp $USER@${client}:~/*${CLIENT_SIMU_OUTPOST} ${prefix}/

    outf=${i}-${DUR}-wrkout.txt
    for j in $CLIENT_LIST
    do
       localout=${j}-${outf}
       client=${j}${VM_POSTFIX}
       scp $USER@${client}:~/$outf ${prefix}/$localout
       log "scp $USER@${client}:~/$outf ${prefix}/$localout"
    done
    # collect server netstat
    # stop the netstat by force because some of the processes may not stop
    stop_netstat
    scp $USER@${SERVER}:/tmp/report.csv ${prefix}/${i}-netstat-report.csv
    log "scp $USER@${SERVER}:/tmp/report.csv ${prefix}/${i}-netstat-report.csv"
  done
}

main() {
  local prefix=`date +%Y_%m_%d_%H_%M_%S`
  run_test $prefix
}

main
#test_gen
