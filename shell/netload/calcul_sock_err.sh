#!/bin/bash
if [ $# -ne 1 ]
then
  echo "specify the result folder"
  exit 1
fi

. env.sh
indir=$1
for i in $CONN_LIST
do
  req_total=`grep "requests in" $indir/*-${i}-* | awk '{s+=$2}END{print s}'`
  timeout_total=`grep "timeout"  $indir/*-${i}-* | awk '{s+=$NF}END{print s}'`
  err_rate=`echo $req_total $timeout_total | awk '{printf("%.2f%s\n", $2/$1*100, "%")}'`
  echo "$i-conn $err_rate" 
  grep "requests in" $indir/*-${i}-* | awk '{print $2}' > /tmp/req
  grep "timeout"  $indir/*-${i}-* | awk '{print $NF}' > /tmp/timeout
  paste /tmp/req /tmp/timeout > /tmp/req_timeout
  awk '{printf("%.2f\n", $2/$1*100)}' /tmp/req_timeout|sort -n -r > /tmp/timeout_rate.txt
  cat /tmp/timeout_rate.txt
done
