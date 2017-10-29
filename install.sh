#!/usr/bin/env bash

# Update VPS
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get autoremove -y
sudo apt -y install pwgen

# If you do not have more than 4G of memory when you add your existing Mem and Swap, add some swap space to the server:
free -h
df -h
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile


# Make the swap come back on after a reboot:
sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab

#Make the swap work better do this for your existing swap even if you did not add any. This setting makes the server
# wait until memory is 90% used before using the hard drive as memory:
sudo echo "vm.swappiness=10" >> /etc/sysctl.conf

free -h
df -h

# Install zen from packages
sudo apt-get install apt-transport-https lsb-release
echo 'deb https://zencashofficial.github.io/repo/ '$(lsb_release -cs)' main' | sudo tee --append /etc/apt/sources.list.d/zen.list
gpg --keyserver ha.pool.sks-keyservers.net --recv 219F55740BBF7A1CE368BA45FB7053CE4991B669
gpg --export 219F55740BBF7A1CE368BA45FB7053CE4991B669 | sudo apt-key add -

sudo apt-get update
sudo apt-get install zen
zen-fetch-params

# -----------------------------------------------------------------------------------------------------------------
# ZEN config
# Run zend once and read the message. It then stops.
zend

# Create a new zen configuration file. Copy and paste this into the command line:
USERNAME=$(pwgen -s 16 1)
PASSWORD=$(pwgen -s 64 1)
sudo echo -e "rpcuser=$USERNAME\nrpcpassword=$PASSWORD\nrpcallowip=127.0.0.1\nserver=1\ndaemon=1\nlisten=1\ntxindex=1\nlogtimestamps=1\n### testnet config\n# testnet=1" >> ~/.zen/zen.conf

# Run the Zen application as a daemon:
zend

# Check status and make sure block are increasing:
zen-cli getinfo
sleep 5s
zen-cli getinfo
#
#
#
#
#    if [ ping -c 1 google.com -eq 0 ]
#    then
#        echo "Error!" 1>&2
#        exit 0
#    fi
#ping -c 1 127.0.0.1 ; echo $?
#
#REACHABLE_DOMAIN=ping -c 1 127.0.0.1 ; echo $?
#if ($REACHABLE_DOMAIN -ne 0); then
#    echo "Error!" 1>&2
#    exit 64
#fi