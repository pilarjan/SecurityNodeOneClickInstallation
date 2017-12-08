#!/usr/bin/env bash

# Upload
NODE="001sn"
scp install_better.sh root@${NODE}:/root/ && scp my_config.sh root@${NODE}:/root/

ssh ${NODE}

sudo chmod +x /root/install_better.sh && sudo chmod +x /root/my_config.sh && source ./install_better.sh && rm /root/my_config.sh && rm /root/my_config.sh

# Backup wallet.dat from node
scp root@${NODE}:/root/.zen/wallet.dat ~/PycharmProjects/SecurityNodeOneClickInstallation/wallets/${NODE}_wallet.dat










