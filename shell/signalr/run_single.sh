#!/bin/bash
sh select_servers.sh
sh regenerate_signalr.sh
sh run_bench.sh
sh gen_report.sh
if [ $# -eq 0 ]
then
  sh publish_report.sh
fi
