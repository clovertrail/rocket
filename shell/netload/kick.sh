#!/bin/bash
dst=http://geoapi.chinaeast.cloudapp.chinacloudapi.cn/app.txt
th=$(nproc)
dur=300s
#dst=http://wcn.chinanorth.cloudapp.chinacloudapi.cn/app.txt
logger -t "WRK_LOG" "./wrk -c 4096 -t $th -d $dur --latency --timeout 5s --connreqs 1 $dst > 4096-300s-wrkout.txt"
./wrk -c 4096 -t $th -d $dur --latency --timeout 5s --connreqs 1 $dst > 4096-300s-wrkout.txt 
