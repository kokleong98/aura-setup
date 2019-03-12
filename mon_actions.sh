#!/bin/bash
#sendmail required postfix service to be install. (sendmail=1 to make email notification)
#
sendmail=0
mail_subject="AURA STAKING OFFLINE."
mail_message="AURA STAKING OFFLINE."
mail_to="Your@email.com"

test=$(aura status | grep 'Staking: offline' -c)
if [ $test -eq 1 ]
then
  if [ $sendmail -eq 1 ]
  then
    echo "$mail_message" | mail -s "$mail_subject" "$mail_to"
  fi

  #stop aura services
  aura stop
  #update aurad
  npm install -g @auroradao/aurad-cli
  #start aura services
  aura start
fi
