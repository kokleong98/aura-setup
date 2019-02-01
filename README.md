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
