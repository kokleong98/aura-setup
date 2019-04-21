#!/bin/bash
####################  DO NOT REMOVE THESE LINES #################### 
# VERSION=0.1.0 
# FILENAME=install-auram-alias.sh
# DESCRIPTION=AURA-M add command aliases installation script
####################################################################
function auram() {
  if [ "$1" == "start" ]; then
    sudo systemctl start auram
  elif [ "$1" == "stop" ]; then
    sudo systemctl stop auram
  elif [ "$1" == "status" ]; then
    sudo systemctl status auram
  elif [ "$1" == "logs" ]; then
    sudo journalctl -u auram -f
  fi
}