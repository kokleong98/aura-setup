#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram.sh
# DESCRIPTION=AURA-M systemd service installation script
####################################################################
if [ $# -lt 1 ]; then
  echo "Insufficient parameters."
  exit 1
fi
username="$1"
DIR="$2"

if [ -z "$DIR" ]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
#########################################
# 1. Create AURA-M systemd service file
#########################################
cat > aura-m.service << EOF
[Unit]
Description=AURA-M monitoring service

[Service]
User=$username
WorkingDirectory=/home/$username/
ExecStart=${DIR}/start-auram.sh
ExecStop=${DIR}/stop-auram.sh
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

sudo mv aura-m.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aura-m.service

sed -i "s/##username##/$username/g" "$DIR/start-auram.sh"

if [ -f "$DIR/auram.conf" ]; then
  read -p "auram.conf existed. Do you want keep the settings? (y/n) " keep_settings
  if [ "$keep_settings" == "y" ]; then
    echo "No changes on existing settings."
    exit 0
  fi
fi

read -p "Do you turn on aurad auto-update? (y/n) " update_auto_accept
if [ "$update_auto_accept" != "y" ]; then
  update_auto=0
else
  update_auto=1
fi

read -p "Do you want to run aurad on rpc endpoint like infura.io? (y/n) " rpc_option_accept
if [ "$rpc_option_accept" != "y" ]; then
  rpc_option=0
else
  read -p "Please enter your rpc endpoint address eg. https://mainnet.infura.io/v3/<your_project_id>. " rpc_url
  rpc_option=1
fi

cat > "$DIR/auram.conf" << EOF
#staking offline count before restart aurad
off_restart=3
#staking offline cooling period after restart aurad
off_cool=10
#send mail on staking offline option
sendmail=0
#send mail on staking offline mail options
mail_subject="AURA STAKING OFFLINE."
mail_message="AURA STAKING OFFLINE."
mail_to=""
#aurad update notification option
update_notify=0
#external ethereum node option
rpc_option=$rpc_option
rpc_url="$rpc_url"
stats_option=1
update_auto=$update_auto
EOF

echo "New settings configured."
exit 0