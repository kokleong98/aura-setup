# Disclaimers
This unofficial guide is based on my personal experience on aura staking and I am not associated with Aurora nor its associates. The provided contents comes with no warranty. You may freely use and modify the software according to your needs.


# aura-setup
Aura staking setup

1. Run following script section to install aurad and dependencies. 
```shell
curl -O https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura-deploy.sh 
chmod +x aura-deploy.sh
sudo ./aura-deploy.sh
```
2. Login with the new user account you have setup on step 1.
3. Run following to configure your staking.
```
aura config
```
4. Fill in your cold wallet address and sign it with ether wallet.

# aura.conf sample configuration
```
#check interval minutes
interval=1
#staking offline count before restart aurad
off_restart=3
#staking offline cooling period after restart aurad
off_cool=10
#send mail on staking offline option (1=Enabled, 0=Default,Disabled)
sendmail=0
#send mail on staking offline mail options
mail_subject="Your mail subject."
mail_message="Your mail messsage."
mail_to="your@email.com"
#aurad update notification option (1=Enabled, 0=Default,Disabled)
update_notify=0
#external ethereum node option (1=Enabled, 0=Default,Disabled)
rpc_option=0
rpc_url=""
```

# aura systemd service setup
Install aura as systemd service auto run aura at system reboot. This have depedency on nvm. The service include following functionality.
- Monitoring staking offline and auto restart aura.
- Auto aura start on system reboot and aura.service failures. 
- Email notification when staking offline (disabled by default, need configuration on aura-start.sh).
- Aurad block sync wait at aura.service start-up.
- Auto restart aurad container when stuck during Aurad block sync stage.
- Aurad software update email notification.
- Support "aura.conf" configuration file.
- **Staking online statistics? (I'm not sure whether want to implement this because a bit outside the scope and add stress to the node)

## Basic aura systemd service setup (Without email notification)
Make sure you have finished sync with the network before starting aura.service else it will restart aura because staking is offline.
1. Run following script section to install aurad service and key in username setup during aura-setup. *You may be prompt for sudo password.
```
curl -O https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura-service-install.sh 
chmod +x aura-service-install.sh
sudo ./aura-service-install.sh
```
You shall see 2 service shell script files (aura-start.sh, aura-stop.sh) created and 1 systemd aura service file (aura.service) created.

2. Upon finish aurad sync. Running following command to start your aura monitoring service.
```
sudo systemctl start aura.service
```
## Advanced aura systemd service setup (With email notification)
1. Run following script section to install aurad service and key in username setup during aura-setup.
```
curl -O https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura-service-install.sh 
chmod +x aura-service-install.sh
sudo ./aura-service-install.sh
```
2. You may further edit aura-start.sh to support email notification. You MUST setup mail relay server using the following guide to make mail notification work else keep setting as sendmail=0.
https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu/
```
sendmail=1
mail_to="your@email.com"
mail_message="custom email content"
mail_subject="custom email subject"
```
3. Upon finish aurad sync and adjusting your aura-start.sh script. Running following command to start your aura monitoring service.
```
sudo systemctl start aura.service
```

# aura droplet migration
Aura droplet migration

1. Setup the new droplet as per aura staking setup above and without signing new node with ether wallet.
2. Stop source droplet aura services.
```
aura stop
```
3. SSH to source droplet and copy ".aurad" directory recursively to new droplet using scp command. Replace <myusername> with your droplet account name and <hostip> droplet public ip address.
```
scp -r ~/.aurad/ <myusername>@<hostip>:~
```

# aura cron staking offline monitoring setup
1. Run following script section to create cron.bash and mon_actions.sh file on account home directory.
```
curl -O https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura.bash
curl -O https://raw.githubusercontent.com/kokleong98/aura-setup/master/mon_actions.sh
chmod +x aura.bash mon_actions.sh
```
2. Setup a recurring cron job to check log status every 5-10 minutes. 
3. Add the following line to your first line of the "crontab -e" command.
```
SHELL=/home/<myusername>/aura.bash
```
4. Add the line below to run on every 5 minutes. Replace <myusername> with your droplet account name.
```
*/5 * * * * /home/<myusername>/mon_actions.sh
```

# add email notification on staking offline restart
1. Complete setup on "aura cron staking offline monitoring setup" above.
2. Setup mail relay server using the guide.
https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu/
3. Edit following internal parameters in "mon_actions.sh" file.
```
sendmail=1
mail_to="your@email.com"
mail_message="custom email content"
mail_subject="custom email subject"
```

# migrate staking wallet only
1. Setup the new droplet as per aura staking setup above and without signing new node with ether wallet.
2. SSH to source droplet and copy ".aurad/ipc" directory recursively to new droplet using scp command. Replace <myusername> with your droplet account name and <hostip> droplet public ip address.
```
scp -r ~/.aurad/ipc <myusername>@<hostip>:~/.aurad/
```
