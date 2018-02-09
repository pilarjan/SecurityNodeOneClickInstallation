#!/usr/bin/env bash

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

############################################################### ssl-certificate: #######################################
case ${SSL_CERTIFICATE_CHOICE} in
    1)
        echo "YOUR OWN CERTIFICATE:"
        if [ -d "/etc/ssl/zen" ]; then
            # Control will enter here if $DIRECTORY exists.
            sudo rm -r /etc/ssl/zen
        fi
        if [ -d "/etc/ssl/zen/private" ]; then
            # Control will enter here if $DIRECTORY exists.
            sudo rm -r /etc/ssl/zen/private
        fi

        sudo mkdir /etc/ssl/zen
        sudo mkdir /etc/ssl/zen/private
        sudo mv ${CERT} /etc/ssl/zen/${HOST_NAME}.crt
        sudo mv ${CERT_KEY} /etc/ssl/zen/private/${HOST_NAME}.key

        if [ -d "/usr/share/ca-certificates/extra" ]; then
            # Control will enter here if $DIRECTORY exists.
            sudo rm -r /usr/share/ca-certificates/extra
        fi
        sudo mkdir /usr/share/ca-certificates/extra
        sudo mv ${CA} /usr/share/ca-certificates/extra/${HOST_NAME}.crt
        sudo dpkg-reconfigure ca-certificates
    ;;
    2)
        echo "LETS ENCRYPT CERTIFICATE:"
        if [ ! -d /${USER}/acme.sh ]; then
            sudo apt-get install socat
            cd /${USER} && git clone https://github.com/Neilpang/acme.sh.git
            cd /${USER}/acme.sh && sudo ./acme.sh --install
            sudo chown -R ${USER}:${USER} /${USER}/.acme.sh
        fi
        if [ ! -f /${USER}/.acme.sh/${HOST_NAME}/ca.cer ]; then
            sudo /${USER}/.acme.sh/acme.sh --issue --standalone -d ${HOST_NAME}
        fi
        cd ~
        sudo cp /${USER}/.acme.sh/${HOST_NAME}/ca.cer /usr/local/share/ca-certificates/${HOST_NAME}.crt
        sudo update-ca-certificates
        CRONCMD_ACME="6 0 * * * \"/$USER/.acme.sh\"/acme.sh --cron --home \"/$USER/.acme.sh\" > /dev/null" && (crontab -l | grep -v -F "$CRONCMD_ACME" ; echo "$CRONCMD_ACME") | crontab -
        echo -e ${purpleColor}"certificates has been installed!"${normalColor}
    ;;
    *)
        echo "Invalid choice to install ssl certificate!"
        exit 1
    ;;
esac

################################################################# packages #############################################
locale-gen en_US en_US.UTF-8 cs_CZ cs_CZ.UTF-8
dpkg-reconfigure locales

# sudo dpkg --configure -a
sudo apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y
sudo apt-get install -y build-essential pkg-config libc6-dev m4 g++-multilib autoconf monit libtool ncurses-dev unzip git htop python zlib1g-dev wget bsdmainutils pwgen automake libgtk2.0-dev monit
# sudo apt-get install -y rkhunter fail2ban
# sudo systemctl enable fail2ban
# sudo systemctl start fail2ban

sudo apt -y install npm
sudo npm install -g n
sudo n 8.9
sudo npm install pm2 -g
sudo apt-get autoremove -y
sudo npm install pm2 -g

################################################################ basic security ########################################
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow http/tcp
sudo ufw allow https/tcp
sudo ufw allow 9033/tcp
sudo ufw logging on
sudo ufw --force enable
echo -e ${purpleColor}"Basic security completed!"${normalColor}

################################################################# Add a swapfile. ######################################
#if [ $(cat /proc/swaps | wc -l) -eq 2 ]; then
#    echo "Configuring your swapfile..."
#    sudo fallocate -l 3G /swapfile
#    sudo chmod 600 /swapfile
#    sudo mkswap /swapfile
#    sudo swapon /swapfile
#    echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
#else
#    echo "Swapfile exists. Skipping."
#fi
#echo -e ${purpleColor}"Swapfile is done!"${normalColor}

#################################### Create an empty zen config file and add new config settings. ######################
if [ -f /${USER}/.zen/zen.conf ]; then
  sudo rm /${USER}/.zen/zen.conf || true
fi
echo "Creating an empty ZenCash config..."
sudo mkdir -p /${USER}/.zen || true
sudo touch /${USER}/.zen/zen.conf

RPC_USERNAME=$(pwgen -s 16 1)
RPC_PASSWORD=$(pwgen -s 64 1)

case ${SSL_CERTIFICATE_CHOICE} in
    1)
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
    ;;
    2)
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
tlscertpath=/$USER/cert/.csr
tlskeypath=/$USER/cert/.key
### testnet config
# testnet=1' >> /$USER/.zen/zen.conf"
    ;;
    *)
        echo "Invalid choice in SSL conf choice!"
        exit 1
    ;;
esac

echo -e ${purpleColor}"zen.conf is done!"${normalColor}

############################################################ Installing zen: ###########################################
case ${ZEN_INSTALL_CHOICE} in
  1)
     echo "BUILD FROM REPO:"
     if ! [ -x "$(command -v zend)" ]; then
       sudo apt-get install apt-transport-https lsb-release -y
       echo 'deb https://zencashofficial.github.io/repo/ '$(lsb_release -cs)' main' | sudo tee --append /etc/apt/sources.list.d/zen.list
       gpg --keyserver ha.pool.sks-keyservers.net --recv 219F55740BBF7A1CE368BA45FB7053CE4991B669
       gpg --export 219F55740BBF7A1CE368BA45FB7053CE4991B669 | sudo apt-key add -

       sudo apt-get update
       sudo apt-get install zen -y

       sudo chown -R ${USER}:${USER} /${USER}/.zen
       zend
       zen-fetch-params
     fi
  ;;
  2)
    echo "BUILD FROM SOURCE:"
    if ! [ -x "$(command -v /${USER}/zen/src/zend)" ]; then
      # Clone ZenCash from Git repo.
      if [ -d /${USER}/zen ]; then
        sudo rm -r /${USER}/zen
      fi
      echo "Downloading ZenCash source..."
      git clone https://github.com/ZencashOfficial/zen.git

      # Download proving keys.
      if [ ! -f /${USER}/.zcash-params/sprout-proving.key ]; then
        echo "Downloading ZenCash keys..."
        sudo /${USER}/zen/zcutil/fetch-params.sh
      fi

      # Compile source.
      echo -e ${purpleColor}"Compiling ZenCash..."${normalColor}
      cd /${USER}/zen && ./zcutil/build.sh -j$(nproc)
      sudo chown -R ${USER}:${USER} /${USER}/.zen

      # copy executable to the bin directory.
      sudo cp /${USER}/zen/src/zend /usr/bin/
      sudo cp /${USER}/zen/src/zen-cli /usr/bin/
    fi
  ;;
  *)
    echo "Invalid choice to install zen. Re-run the script!"
    exit 1
  ;;
esac


# Create a shielded address on the zen node:
zend
sleep 5
zen-cli z_getnewaddress
Z_OUTPUT=`zen-cli z_listaddresses`
Z_OUTPUT2=${Z_OUTPUT:5}
Z_ADDRESS=${Z_OUTPUT2::-3}
zen-cli getnetworkinfo

echo -e ${purpleColor}"Zen installation is finished!"${normalColor}
N_BLOCK=`zen-cli getblockcount`
echo -e ${purpleColor}"Synced # of blocks: "${N_BLOCK}${normalColor}


########################################### run znode and sync chain on startup of VM: #################################
CRONCMD="@reboot /usr/bin/zend" && (crontab -l | grep -v -F "$CRONCMD" ; echo "$CRONCMD") | crontab -
CRONCMD="@reboot cd /root/secnodetracker/ && /usr/local/bin/node app.js &" && (crontab -l | grep -v -F "$CRONCMD" ; echo "$CRONCMD") | crontab -

####################################################### secnodetracker #################################################
if [ ! -d /${USER}/secnodetracker ]; then
  cd /${USER} && git clone https://github.com/ZencashOfficial/secnodetracker.git
  cd /${USER}/secnodetracker && npm install
fi
cd
echo -e ${purpleColor}"secnodetracker added!"${normalColor}

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
sudo echo -n "ts1.eu,ts1.na,ts1.sea,ts2.eu,ts2.na" >> /${USER}/secnodetracker/config/servers

N_BLOCK=`zen-cli getblockcount`
echo -e ${purpleColor}"Synced # of blocks: "${N_BLOCK}${normalColor}

cd

systemctl disable lvm2-monitor.service
systemctl disable lxcfs.service
systemctl disable lxd-containers.service
systemctl disable mdadm.service
systemctl disable ondemand.service
systemctl disable open-iscsi.service

# Optimise your block io:
echo 0 > /sys/block/vda/queue/rotational
echo 0 > /sys/block/vda/queue/rq_affinity

# /etc/sysctl.conf
sudo echo "net.core.rmem_max=16777216" >> /etc/sysctl.conf
sudo echo "net.core.wmem_max=16777216" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_rmem=4096 87380 16777216" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_wmem=4096 65536 16777216" >> /etc/sysctl.conf

# increase swapiness to 80
echo "80" > /proc/sys/vm/swappiness

cd /root/secnodetracker
pm2 start app.js --name secnodetracker
pm2 save
pm2 startup

# add zend autorestarter
sudo echo "### added on setup for zend" >> /etc/monit/monitrc
sudo echo "set httpd port 2812" >> /etc/monit/monitrc
sudo echo "use address localhost # only accept connection from localhost" >> /etc/monit/monitrc
sudo echo "allow localhost # allow localhost to connect to the server" >> /etc/monit/monitrc
sudo echo "### zend process control" >> /etc/monit/monitrc
sudo echo "check process zend with pidfile /root/.zen/zen_node.pid" >> /etc/monit/monitrc
sudo echo 'start program = "/root/zen_node.sh start" with timeout 60 seconds' >> /etc/monit/monitrc
sudo echo 'stop program = "/root/zen_node.sh stop"' >> /etc/monit/monitrc

sudo monit reload
sudo monit start zend
sudo monit status

# clear crontab
crontab -r

# MINUTE=$[ ( $RANDOM % 60 ) ]
# crontab -l | { cat; echo "$MINUTE */1 * * * /usr/bin/pkill -f secnodetracker"; } | crontab -

echo -e ${purpleColor}"Z address: "${Z_ADDRESS}${normalColor}

rm /root/my_config.sh && rm /root/install_better.sh

reboot now
