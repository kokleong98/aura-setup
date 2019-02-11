#!/bin/bash
# create systemd service for aurad daemon
#

read -p "Enter aura service account: " username
getent passwd $username > /dev/null 2&>1
if [ $? -ne 0 ]
then
  echo "Invalid username"
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat > aura.service << EOF
[Unit]
Description=aurad service

[Service]
User=$username
WorkingDirectory=/home/$username/
ExecStart=${DIR}/aura-start.sh
ExecStop=${DIR}/aura-stop.sh

[Install]
WantedBy=multi-user.target
EOF

sudo mv aura.service /etc/systemd/system/

cat > aura-start.sh << EOF
#!/bin/bash
source /home/$username/.nvm/nvm.sh
aura start
sysminutes=\$((\$(date +"%M")))
interval=5
sendmail=0
mail_subject="AURA STAKING OFFLINE."
mail_message="AURA STAKING OFFLINE."
mail_to="Your@email.com"

while :
do
  sysminutes=\$((\$(date +"%M")))
  if [[ \$(docker ps --format "{{.Image}}"  --filter status=running | grep -c auroradao/aurad) -eq 0 ]]; then
    echo "container not running.."
    exit 0
  else
    if [[ \$((\$sysminutes % \$interval)) -eq 0 ]]; then
      echo "container running.."

      test=\$(aura status | grep "Staking: offline" -c)
      if [ \$test -eq 1 ]; then
        if [ \$sendmail -eq 1 ]; then
          echo \$mail_message | mail -s \$mail_message \$mail_to
        fi
      fi
    fi
  fi
  sleep 30;
done
EOF

sudo chmod +x aura-start.sh

cat > aura-stop.sh << EOF
#!/bin/bash
source /home/kokleong/.nvm/nvm.sh
aura stop
EOF

sudo chmod +x aura-stop.sh

sudo systemctl daemon-reload
sudo systemctl enable aura.service
