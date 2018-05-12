#!/bin/bash
. ./bench_env.sh

if [ -d $output_dir ]
then
	rm -fr $output_dir
fi

./sigbench -mode "cli" -outDir $output_dir -agents "localhost:7000" -config $config_file
