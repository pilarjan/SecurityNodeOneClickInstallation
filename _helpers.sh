#!/usr/bin/env bash

NODE=002

# Copy wallet to VPS
scp ./wallets/${NODE}_wallet.dat ${NODE}:/root/.zen/
scp ~/PycharmProjects/SecurityNodeOneClickInstallation/wallets/${NODE}_wallet.dat root@${NODE}:/root/.zen/wallet.dat


# Show number of blocks
echo -e "Synced # of blocks: "`zen-cli getblockcount`


# Others
zen-cli getpeerinfo
zen-cli getinfo
zen-cli z_listaddresses

zen-cli getnetworkinfo
zen-cli z_gettotalbalance
echo -e "Synced # of blocks: "`zen-cli getblockcount`


zen-cli

crontab -e
crontab -r

@reboot /usr/bin/zend
@reboot cd /root/secnodetracker/ && /usr/local/bin/node app.js &


tail -f /proc/<pid>/fd/1

zen-cli stop
sudo monit start zend

sudo monit stop zend
zend --rescan


ssh ${NODE}
sudo monit start zend
zen-cli stop
zend --rescan
zend --reindex


sudo dpkg --configure -a && sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y

sudo apt-get update && apt-get upgrade -y && apt-get autoremove -y && reboot now

