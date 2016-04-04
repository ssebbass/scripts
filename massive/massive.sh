#!/bin/bash
# set -ex

# Check for basic tools
which sshpass >/dev/null 2>&1 || echo "Please install sshpass"
which ssh >/dev/null 2>&1     || echo "Please install ssh client"
which mktemp >/dev/null 2>&1  || echo "Missing mktemp"

# Check for files
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "$0 <HostList> <SshScript> <sshUser> <SSHPass (optional)>"
  exit 1
fi

HOSTLIST="$1"
SCRIPT="$2"
SSHUSR="$3"
PASSWD="$4"                                                                     # This is optional
SSHOPT="-F $HOME/.ssh/config -t -o ConnectTimeout=5 -o ConnectionAttempts=2"    # Some default ssh options
DATE="$( date +%Y%m%d%H%M )"
WORKDIR="$( pwd )"
LOGFILE="$WORKDIR/$(basename $0).$DATE.log"
TMPFILE="$(mktemp)"
TEXTDELIMETER="704e756a950d0d3d38193e013a3e4767"

function clean {
  rm -f $TMPFILE >/dev/null 2>&1
}

function sshwithpasswd {
  for HOST in $( cat $HOSTLIST ); do
    #    echo -e "\n   *** $HOST ***"
    echo haciendo ssh a $HOST
    sshpass -p $PASSWD ssh $SSHOPT $SSHUSR@$HOST < "$SCRIPT" >$TMPFILE 2>&1 ; RETVAL="$?"
    if [ "$RETVAL" = 0 ]; then
      sed "0,/"$TEXTDELIMETER"/d" $TMPFILE
    else
      echo "Error on host $HOST"
      sed "0,/"$TEXTDELIMETER"/d" $TMPFILE
    fi
  done
}

function sshwithoutpasswd {
  for HOST in $( cat $HOSTLIST ); do
    echo -e "\n"
    echo haciendo ssh a $HOST
    ssh $SSHOPT $SSHUSR@$HOST < "$SCRIPT" >$TMPFILE 2>&1 ; RETVAL="$?"
    if [ "$RETVAL" = 0 ]; then
      sed "0,/"$TEXTDELIMETER"/d" $TMPFILE
    else
      echo "Error on host $HOST"
      sed "0,/"$TEXTDELIMETER"/d" $TMPFILE
    fi
  done
}

function main {
  if [ -z "$PASSWD" ] || [ -z "$SSHUSR" ]; then
    sshwithoutpasswd
  else
    sshwithpasswd
  fi
}

main | tee -a $LOGFILE
clean
