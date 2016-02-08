#!/bin/bash
set -e

if [ ! -f "$1" ]; then
  echo Usage: $0 [hosts file]
  exit 1
else
  LIST="$1"
fi

LIMITE="3"
SLEEP="10"
SSHOPT="ssh -F $HOME/.ssh/config -l root"
RSYNC="rsync --delete -qzPhae"

for HOST in $( cat $LIST ) ; do
  mkdir $HOST >/dev/null 2>&1 || true

  while true; do
    HILOS=$(ps -ef | grep "$RSYNC" | grep -v grep | wc -l)
    echo "Hilos = $HILOS - LIMITE = $LIMITE"

    if [ "$HILOS" -gt "$LIMITE" ]; then
      sleep $SLEEP
    else
      echo lanzo rsync $HOST...
      # $RSYNC $HOST:/root/monitoreo/ $HOST:/etc/fstab $HOST:/etc/apache2 $HOST:/etc/sysctl.conf $HOST:/var/log $HOST/ &
      $RSYNC "$SSHOPT" $HOST:/root/monitoreo/ $HOST:/etc/fstab $HOST:/etc/apache2 $HOST:/etc/sysctl.conf $HOST/ &
      sleep 1
      break  
    fi

  done
done

while true; do
  if [ "$( ps -ef | grep -v grep | grep "$RSYNC" )" != "" ]; then
    echo -e ".\c"
    sleep 1
  else
    exit 0
  fi
done
  
