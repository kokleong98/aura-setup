#!/bin/bash
#check whether last 10 consecutives staking offline
test=$(aura logs | grep STAKING | tail -n 10 | grep OFFLINE -c)
if [ $test -eq 10 ]
then
  #stop aura services
  aura stop
  #update aurad
  npm install -g @auroradao/aurad-cli
  #start aura services
  aura start
fi
