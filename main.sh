#!/usr/bin/env bash


#-------------------------------------------------- STEP 1 -------------------------------------------------------------
NODE=177

ssh-copy-id ${NODE}


#-------------------------------------------------- STEP 2 -------------------------------------------------------------
scp ./cert/CA.crt ./cert/cert.crt ./cert/my_key.key install_better.sh my_config.sh zen_node.sh ${NODE}:/root/

ssh ${NODE}

sudo chmod +x /root/install_better.sh && sudo chmod +x /root/my_config.sh && sudo chmod u+x /root/zen_node.sh

source ./install_better.sh


#-------------------------------------------------- STEP 3 -------------------------------------------------------------
# Backup wallet.dat from node
scp root@${NODE}:/root/.zen/wallet.dat ./wallets/${NODE}_wallet.dat
scp root@${NODE}:/root/.zen/wallet.dat ./wallets_backup/${NODE}_wallet.dat
