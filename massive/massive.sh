#!/bin/bash
# set -x

# Check for basic tools
which sshpass >/dev/null 2>&1 || echo "Please install sshpass"
which ssh >/dev/null 2>&1 || echo "Please install ssh client"
which mktemp >/dev/null 2>&1 || echo "Missing mktemp"

# Check for files
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "$0 <Host list file> <Script to run on the client> <SSH user (optional)> <SSH Password (optional)>"
  exit 1
fi

HOSTLIST="$1"
SCRIPT="$2"
SSHUSR="$3"
PASSWD="$4"                                                                     # This is optional
SSHOPT="-o ConnectTimeout=5 -o ConnectionAttempts=2"                       # Some default ssh options
DATE=$(date +%Y%m%d%H%M)
LOGFILE="$0.$DATE.log"
TMPFILE="$(mktemp)"

function clean {
  rm -f $TMPFILE >/dev/null 2>&1
}

function sshwithpasswd {
  sshpass -p $PASSWD ssh $SSHOPT $SSHUSR@$HOST < "$SCRIPT" 2>/dev/null > tmpfile
}

function sshwithoutpasswd {
  echo ssh without a passwd
}

function main {
  if [ -z "$PASSWD" ] || [ -z "$SSHUSR" ]; then
    sshwithoutpasswd
  else
    sshwithpasswd
  fi
}

echo $0

#      RETOURNEDMSG="`cat tmpfile | sed '0,/HEADERTEXT/d'`"
# Main call

main
clean
# | tee -a $LOGFILE 

