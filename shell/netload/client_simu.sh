#!/bin/sh

if [ $# -ne 4 ]
then
  echo "Specify CONN, MAX timeout, URL, OUTPOST"
  exit 1
fi
CONN=$1
MAX=$2
URL=$3
OUTPOST=$4
LOG_FILE=${CONN}-${OUTPOST}

probe() {
   local index=$1
   local start_date=`date +%Y-%m-%d-%H-%M-%S`
   echo -n "$index " $start_date " ">> $LOG_FILE
   curl -o /dev/null -s -w %{time_total} $URL >> $LOG_FILE
   echo "" >> $LOG_FILE
}

if [ -e $LOG_FILE ]
then
  rm $LOG_FILE
fi

i=0
while [ $i -le $MAX ]
do
   probe $i
   sleep 1
   i=`expr $i + 1`
done
