#!/bin/bash
#sendmail required postfix service to be install. (sendmail=1 to make email notification)
#
sendmail=0
mail_subject="AURA STAKING OFFLINE."
mail_message="AURA STAKING OFFLINE."
mail_to="Your@email.com"

#check whether last 10 consecutives staking offline
test=$(aura logs | grep STAKING | tail -n 10 | grep OFFLINE -c)
if [ $test -eq 10 ]
then
  if [ sendmail -eq 1 ]
  then
    echo $mail_message | mail -s $mail_message $mail_to
  fi

  #stop aura services
  aura stop
  #update aurad
  npm install -g @auroradao/aurad-cli
  #start aura services
  aura start
fi
