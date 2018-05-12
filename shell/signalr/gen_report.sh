#!/bin/bash
. ./func_env.sh

result_root=20180323122255
result_dir=$result_root
gen_html
gen_all_report
gen_summary
