#!/usr/bin/env bash

hosts=(192.168.0.1 173.194.222.113 87.250.250.24)

for i in {1..5}
do
    for h in ${hosts[@]}
    do
      nc -zw1  $h 80
      excode=$?
      echo $(date +"%b %d %T") "- check -" $h "- exite code:" $excode >>hosts.log
    done
done
