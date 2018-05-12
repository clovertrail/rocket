#!/bin/bash
declare -i i
MAX=360

outd=/tmp
if [ $# -eq 1 ]
then
  MAX=$1
fi

log() {
  local TAG=""
  local msg="$1"
  logger $TAG "$msg"
}

netstat_func() {
   local i=0
   local outdir=$1
   local timestamp
   local short_tstamp
   local rawf resf
   local tw est last_ack close fin1 fin2 syn total
   local final_content=$outdir/content.csv 
   local tmp_content=$outdir/tmp_content.csv
   local content_title=$outdir/title.csv
   local final_report=$outdir/report.csv

   if [ -e $content_title ]
   then
     rm $content_title
   fi

   rm $outdir/*.txt
   rm $outdir/*.csv

   echo "TIME_WAIT" > $final_content
   echo "ESTAB" >> $final_content
   echo "LAST_ACK" >> $final_content
   echo "FIN_WAIT1" >> $final_content
   echo "FIN_WAIT2" >> $final_content
   echo "SYN_RECV" >> $final_content
   echo "CLOSING" >> $final_content
   echo "TCP-NUM" >> $final_content
   
   while [ $i -le $MAX ]
do
   timestamp=`date +%Y-%m-%d-%H-%M-%S`
   short_tstamp=`date +%M:%S`
   echo -n ",$short_tstamp" >> $content_title
   rawf=$outdir/${timestamp}_netstat_raw.txt
   resf=$outdir/${timestamp}_result.txt
   netstat -an --inet --tcp > $rawf
   log "$i: $timestamp"
   tw=`grep TIME_WAIT $rawf|wc -l`
   est=`grep ESTABLISHED $rawf|wc -l`
   last_ack=`grep LAST_ACK $rawf|wc -l`
   close=`grep CLOSING $rawf|wc -l`
   fin1=`grep FIN_WAIT1 $rawf|wc -l`
   fin2=`grep FIN_WAIT2 $rawf|wc -l`
   syn=`grep SYN_RECV $rawf|wc -l`
   total=`expr $tw + $est + $last_ack + $close + $fin1 + $fin2 + $syn`

   echo "$tw" > $resf
   echo "$est" >> $resf
   echo "$last_ack" >> $resf
   echo "$fin1" >> $resf
   echo "$fin2" >> $resf
   echo "$syn" >> $resf
   echo "$close" >> $resf 
   echo "$total" >> $resf

   paste -d , $final_content $resf > $tmp_content
   mv $tmp_content $final_content
   sleep 1
   i=`expr $i + 1`
done
   echo "" >> $content_title
   cat $content_title > $final_report
   cat $final_content >> $final_report
}
netstat_func $outd
