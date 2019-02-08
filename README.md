# aura-setup
Aura staking setup

1. Make sure you are in root interactive mode.
```
sudo -i
```
2. Run following script section to install aurad and dependencies. 
```shell
wget https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura-deploy.sh 
chmod +x aura-deploy.sh
./aura-deploy.sh
```
3. Login with the new user account you have setup on step 2.
4. Run following to configure your staking.
```
aura config
```
5. Fill in your cold wallet address and sign it ether wallet.

# aura droplet migration
Aura droplet migration

1. Setup the new droplet as per aura staking setup above and complete signing new node with ether wallet.
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
wget https://raw.githubusercontent.com/kokleong98/aura-setup/master/aura.bash
wget https://raw.githubusercontent.com/kokleong98/aura-setup/master/mon_actions.sh
chmod +x aura.bash mon_actions.sh
```
2. Setup a recurring cron job to check log status every 5-10 minutes. 
3. Add the following line to your first line of the "crontab -e" command.
```
SHELL=/home/<myusername>/cron.bash
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
