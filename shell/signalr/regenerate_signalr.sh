#!/bin/bash
. ./env.sh
if [ $build_signalr -eq 1 ]
then
	sh buildsignlar.sh
fi
if [ $generate_appsettings -eq 1 ]
then
	sh genappsettings.sh
fi

sh signalrstop.sh
if [ $deploy_signalr -eq 1 ]
then
	sh deploysignalr.sh
fi
sh signalrstart.sh
