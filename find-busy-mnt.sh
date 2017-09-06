#!/bin/bash

# A script to collect information about dead container mount points 

IDS=`docker ps --format {{.ID}} -f status=dead`

if [ -z "$IDS" ];then
  echo "No dead containers found"
  exit 0
fi


printf "ID\t\tPID\tNAME\t\tMNTNS\n"
echo "$IDS" | while read ID; do 
  MOUNTS=`find /proc/*/mounts | xargs grep $ID 2>/dev/null`

  [ -z "$MOUNTS" ] &&  echo "No pids found" && exit 0

  echo "$MOUNTS" | while read LINE; do
    PID=`echo $LINE | cut -d ":" -f1 | cut -d "/" -f3`
    # Ignore self and thread-self
    if [ "$PID" == "self" ] || [ "$PID" == "thread-self" ]; then
      continue
    fi
    NAME=`ps -q $PID -o comm=`
    MNTNS=`readlink /proc/$PID/ns/mnt`
    printf "%s\t%s\t%s\t\t%s\n" "$ID" "$PID" "$NAME" "$MNTNS"
  done
done 
