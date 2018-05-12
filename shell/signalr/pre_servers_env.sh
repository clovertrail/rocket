#!/bin/bash
# specify 3 servers for build, deploy and bench test
# bench server
master1_host="signalrlinux1.southeastasia.cloudapp.azure.com"
master1_port=22
master1_user="honzhan"

slave1_host="signalrlinux2.southeastasia.cloudapp.azure.com"
slave1_port=22
slave1_user="honzhan"

slave2_host="signalrlinux3.southeastasia.cloudapp.azure.com"
slave2_port=22
slave2_user="honzhan"
# service server
#server2_host="signalr1.southeastasia.cloudapp.azure.com"
#server2_port=50004
#server2_user="honzhan"

# app server
#server3_host="signalr1.southeastasia.cloudapp.azure.com"
#server3_port=50005
#server3_user="honzhan"

service_port=5001
server_port=5050
use_internal_net=1 # 1 means internal network, 0 means external network
