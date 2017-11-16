#!/bin/bash
set -e
PROFILE="$1"
QUERYSTRING="$2"

function usage {
  echo "$0 [AWS PROFILE] [Name tag query string]"
}

function check {
  if [ "$PROFILE" = "" ]; then
    usage
    exit 1
  elif [ "$QUERYSTRING" = "" ]; then
    usage
    exit 1
  fi
}

function getinstanceid {
  aws \
    --profile "$PROFILE" \
    ec2 describe-instances \
    --filters "Name=tag:Name,Values="*"$QUERYSTRING"*"" \
    --output text \
    --query 'Reservations[].Instances[].InstanceId'
}

function getnametag {
  aws \
    --profile "$PROFILE" \
    ec2 describe-tags \
    --filters "Name=resource-id,Values=$INSTANCEID" \
    --output table \
    | grep "$INSTANCEID" \
    | tr -d \| \
    | awk '{ print $4  }'
}

function getprivateipaddress {
    aws --profile "$PROFILE" \
    ec2 describe-instances \
    --instance-id "$INSTANCEID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    | grep -v -e "]" -e "\[" \
    | tr -d \" \
    | awk '{ print $1 }'
}

function getvpc {
  aws --profile "$PROFILE" \
    ec2 describe-instances \
    --instance-id "$INSTANCEID" \
    --query 'Reservations[].Instances[].NetworkInterfaces[].VpcId' \
    | grep -v -e "]" -e "\[" \
    | tr -d \" \
    | awk '{ print $1 }'
}

function getsubnet {
  aws --profile "$PROFILE" \
    ec2 describe-instances \
    --instance-id "$INSTANCEID" \
    --query 'Reservations[].Instances[].NetworkInterfaces[].SubnetId' \
    | grep -v -e "]" -e "\[" \
    | tr -d \" \
    | awk '{ print $1 }'
}

function getinstancetype {
  aws --profile "$PROFILE" \
    ec2 describe-instances \
    --instance-id "$INSTANCEID" \
    --query 'Reservations[].Instances[].InstanceType' \
    | grep -v -e "]" -e "\[" \
    | tr -d \" \
    | awk '{ print $1 }'
}

function list {
  echo "Instance Type,Instance ID,Name,VPC,Subnet,Private IP"
  for INSTANCEID in $( getinstanceid ); do
    echo "$(getinstancetype),$INSTANCEID,$(getnametag),$(getvpc),$(getsubnet),$(getprivateipaddress)"
  done
}

function main {
  check
  list
}

main

