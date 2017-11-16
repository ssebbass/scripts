<F24><F25><F24><F25><F24><F25>#!/bin/bash
set -e

# Just generate a file with all your instance IDs and run:
# script.sh [AWS PROFILE] [list file]

PROFILE="$1"
LISTFILE="$2"

function usage {
  echo "$0 [AWS PROFILE] [LIST FILE WITH INSTANCES IDS]"
}

function check {
  if [ "$PROFILE" = "" ]; then
    usage
    exit 1
  elif [ "$LISTFILE" = "" ]; then
    usage
    exit 1
  fi

  if [ ! -f "$LISTFILE" ]; then
    echo "$LISTFILE not found"
    exit 1
  fi
}

function aws-query {
    aws --profile "$PROFILE" \
    ec2 describe-instances \
    --instance-id "$ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    | grep -v -e "]" -e "\[" \
    | tr -d \" \
    | awk '{ print $1 }'
}

function query-loop {
  while read ID; do
    echo "$ID $(aws-query)"
  done < "$LISTFILE"
}

function main {
  check
  query-loop
}

main

