#!/usr/bin/env bash

rm log_SN_installation.txt

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i log_SN_installation.txt)

# Without this, only stdout would be captured - i.e. your log file would not contain any error messages.
exec 2>&1

########################################## Set environment variables ###################################################
# Quit on any error.
set -e
purpleColor="\033[0;95m"
normalColor="\033[0m"

source my_config.sh
HOST=${HOST_NAME:0:3}
declare T_ADDRESS_NAME=T_ADDRESS_${HOST}
T_ADDRESS=${!T_ADDRESS_NAME}

echo ${T_ADDRESS_NAME}
echo ${T_ADDRESS}

# read -p "Enter Host Name (a.example.com): "
if [[ ${HOST_NAME} == "" ]]; then
  echo "HOST name is required!"
  exit 1
fi

echo -e ${purpleColor}"---------------------------------------------------------------------------------"
echo -e ${purpleColor}"T address: $T_ADDRESS"
echo -e ${purpleColor}"Email: $MAIL"
echo -e ${purpleColor}"Host name: $HOST_NAME"
echo -e ${purpleColor}"FQDN: $FQDN"
echo -e ${purpleColor}"User: $USER"
echo -e ${purpleColor}"IP version: $IPv"
echo -e ${purpleColor}"Region: $REGION"
if [ "${ZEN_INSTALL_CHOICE}" -eq "1" ]; then
    echo -e ${purpleColor}"Install ZEN from: repository (default)"
else
    echo -e ${purpleColor}"Install ZEN from: source"
fi
echo -e ${purpleColor}"---------------------------------------------------------------------------------"${normalColor}


# ---------------------------------------- DELETE PREVIOUS SETTING -----------------------------------------------------
if pgrep zend; then pkill zend; fi
if pgrep node; then pkill node; fi
#killall zend
#killall node

if [ -f /root/.zen/zen.conf ]; then
    echo "zen.conf found! Deleting"
    sudo rm /root/.zen/zen.conf
fi

if [ -f /root/.zen/wallet.dat ]; then
    echo "wallet.dat found! Deleting"
    sudo rm /root/.zen/wallet.dat
fi

if [ -f /etc/ssl/zen/045.security-node.cloud.crt ]; then
    echo "045.security-node.cloud.crt found! Renaming"
    sudo mv /etc/ssl/zen/045.security-node.cloud.crt /etc/ssl/zen/${HOST_NAME}.crt
fi

if [ -f /etc/ssl/zen/private/045.security-node.cloud.key ]; then
    echo "045.security-node.cloud.key found! Renaming"
    sudo mv /etc/ssl/zen/private/045.security-node.cloud.key /etc/ssl/zen/private/${HOST_NAME}.key
fi

if [ -d "/root/secnodetracker/config" ]; then
    # Control will enter here if $DIRECTORY exists.
    sudo rm -r /root/secnodetracker/config
fi

if [ -f /usr/share/ca-certificates/extra/045.security-node.cloud.crt ]; then
    echo "045.security-node.cloud.crt found! Renaming"
    sudo mv /usr/share/ca-certificates/extra/045.security-node.cloud.crt /usr/share/ca-certificates/extra/${HOST_NAME}.crt
    sudo dpkg-reconfigure ca-certificates
fi

# ---------------------------------------- DELETE PREVIOUS SETTING -----------------------------------------------------
echo "Creating an empty ZenCash config..."
RPC_USERNAME=$(pwgen -s 16 1)
RPC_PASSWORD=$(pwgen -s 64 1)

        sudo sh -c "echo 'addnode=$HOST_NAME
addnode=zennodes.network
rpcuser=$RPC_USERNAME
rpcpassword=$RPC_PASSWORD
rpcport=18231
rpcallowip=127.0.0.1
server=1
daemon=1
listen=1
txindex=1
logtimestamps=1
# ssl
tlscertpath=/etc/ssl/zen/$HOST_NAME.crt
tlskeypath=/etc/ssl/zen/private/$HOST_NAME.key
### testnet config
# testnet=1' >> /$USER/.zen/zen.conf"

echo -e ${purpleColor}"zen.conf is done!"${normalColor}

############################################### create new wallet.dat ##################################################
# Create a shielded address on the zen node:
zend

secs=$((40))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

zen-cli z_getnewaddress
Z_OUTPUT=`zen-cli z_listaddresses`
Z_OUTPUT2=${Z_OUTPUT:5}
Z_ADDRESS=${Z_OUTPUT2::-3}
zen-cli getnetworkinfo

echo -e ${purpleColor}"Zen recreation wallet.dat is finished!"${normalColor}

############################################### sec-node-tracker-config ################################################
cd secnodetracker
if [ -d "/root/secnodetracker/config" ]; then
    # Control will enter here if $DIRECTORY exists.
    sudo rm -r /root/secnodetracker/config
fi
mkdir config

touch /${USER}/secnodetracker/config/stakeaddr
sudo echo -n ${T_ADDRESS} >> /${USER}/secnodetracker/config/stakeaddr

touch /${USER}/secnodetracker/config/email
sudo echo -n ${MAIL} >> /${USER}/secnodetracker/config/email

touch /${USER}/secnodetracker/config/fqdn
sudo echo -n ${FQDN} >> /${USER}/secnodetracker/config/fqdn

touch /${USER}/secnodetracker/config/ipv
sudo echo -n ${IPv} >> /${USER}/secnodetracker/config/ipv

touch /${USER}/secnodetracker/config/region
sudo echo -n ${REGION} >> /${USER}/secnodetracker/config/region

touch /${USER}/secnodetracker/config/home
sudo echo -n "ts1."${REGION} >> /${USER}/secnodetracker/config/home

touch /${USER}/secnodetracker/config/rpchost
sudo echo -n "127.0.0.1" >> /${USER}/secnodetracker/config/rpchost

touch /${USER}/secnodetracker/config/rpcpassword
sudo echo -n ${RPC_PASSWORD} >> /${USER}/secnodetracker/config/rpcpassword

touch /${USER}/secnodetracker/config/rpcport
sudo echo -n "18231" >> /${USER}/secnodetracker/config/rpcport

touch /${USER}/secnodetracker/config/rpcuser
sudo echo -n ${RPC_USERNAME} >> /${USER}/secnodetracker/config/rpcuser

touch /${USER}/secnodetracker/config/servers
sudo echo -n "ts1.eu,ts1.na,ts1.sea" >> /${USER}/secnodetracker/config/servers

N_BLOCK=`zen-cli getblockcount`
echo -e ${purpleColor}"Synced # of blocks: "${N_BLOCK}${normalColor}

echo -e ${purpleColor}"Z address: "${Z_ADDRESS}${normalColor}

rm /root/my_config.sh && rm /root/mod_replicated.sh

# sudo apt-get update && apt-get upgrade -y

reboot now
