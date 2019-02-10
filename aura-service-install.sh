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

while :
do
  if [[ \$(docker ps --format "{{.Image}}"  --filter status=running | grep -c auroradao/aurad) -eq 1 ]]; then
    echo "container running.."
  else
    echo "container not running.."
    exit 0
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
