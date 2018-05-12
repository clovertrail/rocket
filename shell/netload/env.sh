#!/bin/sh
CLIENT_LIST="geot1 geot2 geot3 geot4 geot5"
VM_POSTFIX=".chinaeast.cloudapp.chinacloudapi.cn"
SERVER="geoapi.chinaeast.cloudapp.chinacloudapi.cn"
SERVER_URL="http://${SERVER}/app.txt"
KICK_SCRIPT=kick.sh
CLIENT_SIMU_SCRIPT=clientsimu.sh
CLIENT_SIMU_OUTPOST=simu-geoapi.txt
CONN_LIST="2048 4096"
DUR_SE=300  # seconds
DUR=${DUR_SE}s
TIMEOUT=5s
USER=honzhan
