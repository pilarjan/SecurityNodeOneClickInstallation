#!/usr/bin/env bash

sudo apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y

node -v
USER=$(whoami)

cd secnodetracker
git checkout -- package.json
git fetch origin
git checkout master
git pull
cd

sudo echo "ts2.eu,ts2.na,ts1.sea,ts1.eu,ts1.na" > /${USER}/secnodetracker/config/servers

echo "UPDATE HAS BEEN COMPLETED!"

reboot now
