#!/bin/bash
# set -x

# Some initial variables
SSHOPT="-o ConnectTimeout=5 -o ConnectionAttempts=2"
DATE="$( date +%Y%m%d%H%M )"
SRVHOSTSFILE="$1"
SRVSSHUSR="$2"
SRVSSHPASS="$3"
LOGFILE="$0.$DATE.log"

# Test for missing tools
TOOLS="sshpass ssh date"

for TOOL in $TOOLS; do
  which $TOOL >/dev/null 2>&1
  RETVAL="$?"
  if [ "$RETVAL" != "0" ]; then
    echo $TOOL not found
    exit 1
  fi
done


function doSshCopyId {
  SSHPASSWD="$1"
  SSHHOST="$2"
  SSHUSR="$3"
  sshpass -p "$SSHPASSWD" ssh-copy-id $SSHOPT $SSHUSR@$SSHHOST >/dev/null 2>&1
  RETVAL="$?"
  if [ "$RETVAL" = "0" ]; then
    echo $SSHHOST OK
    return 0
  else
    echo ssh to $SSHHOST with user $SSHUSR and password $SSHPASSWD ERROR
    return 1
  fi
}

function walkServers {
  for SERVER in $( cat $SRVHOSTSFILE ); do
    doSshCopyId $SRVSSHPASS $SERVER $SRVSSHUSR
  done
}

function testOptions {
  if [ -z "$SRVHOSTSFILE" ] || [ -z "$SRVSSHUSR" ] || [ -z "$SRVSSHPASS" ]; then
    echo "$0 <hosts list file> <ssh user> <ssh password>"
    exit 1
  fi
  if [ -f "$SRVHOSTSFILE" ]; then
      echo Running $0 $SRVHOSTSFILE $SRVSSHUSR $SRVSSHPASS on $DATE
    else
      echo Check "$SRVHOSTSFILE"
    exit 1
  fi
}

function main {
  testOptions
  walkServers
}

main | tee -a $LOGFILE
