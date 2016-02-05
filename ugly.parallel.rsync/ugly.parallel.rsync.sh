#!/bin/bash
set -e

LIMITE="5"
SLEEP="10"
RSYNC="rsync --delete -qPhae"

for HOST in $( cat lista ) ; do
  mkdir $HOST >/dev/null 2>&1 || true

  while true; do
    HILOS=$(ps -ef | grep "$RSYNC" | grep -v grep | wc -l)
    echo "Hilos = $HILOS - LIMITE = $LIMITE"

    if [ "$HILOS" -gt "$LIMITE" ]; then
      sleep $SLEEP
    else
      echo lanzo rsync $HOST...
      $RSYNC "ssh -l root" $HOST:/root/monitoreo/ $HOST/ &
      break  
    fi

  done

done
