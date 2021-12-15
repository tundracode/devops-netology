#!/usr/bin/env bash

hosts=(192.168.0.1 173.194.222.113 87.250.250.24)

for i in {1..5}
do
    for h in ${hosts[@]}
    do
      nc -zw1  $h 80
      if [ "$?" -eq  0 ]
      then
            excode=$?
            echo $(date +"%b %d %T") "- ok -" $h "- exit code:" $excode >> hosts.log
      else
            excode=$?
            echo $(date +"%b %d %T") "- failure -" $h "- exit code:" $excode >> error.log
            exit
      fi
    done
done
