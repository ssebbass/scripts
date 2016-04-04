#!/bin/bash
# set -x

# Some initial variables
SSHOPT="-t -o ConnectTimeout=5 -o ConnectionAttempts=2"
DATE="$( date +%Y%m%d%H%M )"
SRVHOSTSFILE="$1"
SRVSSHUSR="$2"
SRVSSHPASSFILE="$3"
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


function doSsh {
  SSHPASSWD="$1"
  SSHHOST="$2"
  SSHUSR="$3"
  sshpass -p "$SSHPASSWD" ssh $SSHOPT $SSHUSR@$SSHHOST "uname -n" >/dev/null 2>&1
  RETVAL="$?"
  if [ "$RETVAL" = "0" ]; then
    echo ssh to $SSHHOST with user $SSHUSR and password $SSHPASSWD OK
    return 0
  else
    echo ssh to $SSHHOST with user $SSHUSR and password $SSHPASSWD ERROR
    return 1
  fi
}

function walkServers {
  for SERVER in $( cat $SRVHOSTSFILE ); do
    for PASS in $( cat $SRVSSHPASSFILE ); do
      doSsh "$PASS" "$SERVER" "$SRVSSHUSR"
      if [ "$?" = "0" ]; then
        break
      fi
    done
  done
}

function testOptions {
  if [ -z "$SRVHOSTSFILE" ] || [ -z "$SRVSSHUSR" ] || [ -z "$SRVSSHPASSFILE" ]; then
    echo "$0 <hostList> <sshUser> <ssh password file>"
    exit 1
  fi
  if [ -f "$SRVHOSTSFILE" ] || [ -f "$SRVSSHPASSFILE" ]; then
      echo Running $0 $SRVHOSTSFILE $SRVSSHUSR $SRVSSHPASSFILE on $DATE
    else
      echo Check "$SRVHOSTSFILE & $SRVSSHPASSFILE"
    exit 1
  fi
}

function main {
  testOptions
  walkServers
}

main | tee -a $LOGFILE
