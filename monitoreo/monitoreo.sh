#!/bin/bash
# set -x
## Simple bash monitoring script to gather metrics from some key services

WORKDIR=$(pwd)

function requiretest {
  RUNUSER="root"
  REQUIRES="
    date
    time
    netstat
    grep
    wc
    sar
    awk
    time
    md5sum
    curl
    grep
    cat 
    lsof"

  if [ "$( whoami )" != "root" ]; then
    echo "You have to run this script as superuser"
    exit 1
  fi

  for REQ in $REQUIRES; do
    which $REQ >/dev/null 2>&1 ; RETVAL="$?"
    if [ "$RETVAL" != "0" ]; then
      echo "$REQ not found, please make sure you have: $REQUIRES"
      exit 1
    fi
  done  
}

function print_stats {
  MD5FILE="/mnt/FinalContent/MP4/201503/WMP4H23383MTCR_full/WMP4H23383MTCR_full.mp4"
  DATE=$(date +"%Y-%m-%d")
  TIME=$(date +"%H:%M")
  CURRENT_CON=$(netstat -antp | grep apache2 | grep ESTABLISHED | wc -l)
  BLOCKED_FOR_IO=$(sar -q 3 3 | grep Average | awk '{ print $7 }')
  LAVG=$(sar -q 3 3 | grep Average | awk '{ print $5 }')
  MD5TIME=$( { time md5sum $MD5FILE >/dev/null; } |& grep real | awk '{ print $2}' )
  HTTPBUSYW=$( curl http://127.0.0.1/server-status?auto 2>/dev/null | grep "BusyWorkers" | awk '{ print $2 }')
  HTTPIDDLEW=$( curl http://127.0.0.1/server-status?auto 2>/dev/null | grep "IdleWorkers" | awk '{ print $2 }')
  OPENFILES=$(cat /proc/sys/fs/file-nr | awk '{ print $1 }')
  OPENFILES_FCON=$( lsof | grep /mnt/FinalContent | wc -l )
  
  echo "$DATE;$TIME;$CURRENT_CON;$BLOCKED_FOR_IO;$LAVG;$MD5TIME;$HTTPBUSYW;$HTTPIDDLEW;$OPENFILES;$OPENFILES_FCON"
}

function otherstats {
  DATE=$(date +"%Y-%m-%d")
  TIME=$(date +"%H:%M")
  [ ! -d "$WORKDIR/$DATE" ] && mkdir -p "$WORKDIR/$DATE"
  lsof 2>/dev/null | bzip2 -c > $WORKDIR/$DATE/lsof-$TIME.bz2 &
  iotop -b -n 2 2>/dev/null | bzip2 -c > $WORKDIR/$DATE/iotop.$TIME.bz2 &
  ps aux 2>/dev/null | grep 'apache2' | bzip2 -c > $WORKDIR/$DATE/ps-aux.$TIME.bz2 &
  nfsstat -rc 2>/dev/null | bzip2 -c > $WORKDIR/$DATE/nfsstat-rc.$TIME.bz2 &
  nfsstat -c 2>/dev/null | bzip2 -c > $WORKDIR/$DATE/nfsstat-c.$TIME.bz2 &
  nfsiostat-sysstat -h -t  | bzip2 -c > $WORKDIR/$DATE/nfsstat-h-t.$TIME.bz2 &
}

function logfile {
  DATE=$(date +"%Y-%m-%d")
  echo "$WORKDIR/stats-$DATE.csv"
}

function printhead {
  echo "DATE;TIME;ESTCONN;BIO;ldavg-5;MD5TIME;HTTPBUSYW;HTTPIDDLEW;OPENFILES;OPENFILES_FCON" | tee -a `logfile`
}

function main {
  while true; do
    limpia
    otherstats
    sleep 300
  done
}

function limpia {
  find $WORKDIR -maxdepth 1 -type d -ctime +5 -exec rm -Rf {} \; >/dev/null 2>&1 || true
}

requiretest
main
