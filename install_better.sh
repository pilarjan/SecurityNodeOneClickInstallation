#!/usr/bin/env bash

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i log_SN_installation.txt)

# Without this, only stdout would be captured - i.e. your log file would not contain any error messages.
exec 2>&1

# IMPORTANT: Run this script from /root/ directory: bash -c "$(curl SCRIPT_URL)"
# Once you get the VM up and running you need to login with your root account and run below commands.
sudo apt-get update && apt-get upgrade -y
sudo apt-get install -y build-essential pkg-config libc6-dev m4 g++-multilib autoconf monit libtool ncurses-dev unzip\
git htop python zlib1g-dev wget bsdmainutils automake libgtk2.0-dev && apt-get autoremove -y

#ztjA9FPG1h92AAZYKhA6RUnggVLLinjiDGLbeR5wFKtt4LPd7TQgA9ufkRVSvVEj7eQUiWMrmjD2C8FEVw8KUufkbbCfcQ8
T_ADDRESSES=(zthKXBuBcRmc9bJdy6mHkcYmoZ4uxJa34oA\
             two\
             three)

########################################## Set environment variables ###################################################
# Quit on any error.
set -e
purpleColor='\033[0;95m'
normalColor='\033[0m'

HOST=$(hostname -f)
T_ADDRESS=T_ADDRESSES[ ${HOST} ]
MAIL=
DOMAIN=
HOST_NAME=${HOST}.${DOMAIN}
FQDN=${HOST_NAME}
USER=$(whoami)
IPv=4
REGION=eu

# read -p "Enter Host Name (a.example.com): " HOST_NAME
if [[ ${HOST_NAME} == "" ]]; then
  echo "HOST name is required!"
  exit 1
fi

# zen installation method:
# DEFAULT="1"
# read -p "Enter 1 to build ZEN from repo; enter 2 to build from source: (default 1)" ZEN_INSTALL_CHOICE
# ZEN_INSTALL_CHOICE="${ZEN_INSTALL_CHOICE:-${DEFAULT}}"
ZEN_INSTALL_CHOICE=1


echo -e ${purpleColor}"Host: $HOST\n"${normalColor}
echo -e ${purpleColor}"T address: $T_ADDRESS\n"${normalColor}
echo -e ${purpleColor}"Email: $MAIL\n"${normalColor}
echo -e ${purpleColor}"Domain: $DOMAIN\n"${normalColor}
echo -e ${purpleColor}"Host name: $HOST_NAME\n"${normalColor}
echo -e ${purpleColor}"FQDN: $FQDN\n"${normalColor}
echo -e ${purpleColor}"User: $USER\n"${normalColor}
echo -e ${purpleColor}"IP version: $IPv\n"${normalColor}
echo -e ${purpleColor}"Region: $REGION\n"${normalColor}
if [[${ZEN_INSTALL_CHOICE} == 1]]; then
    echo -e ${purpleColor}"Install ZEN from repository\n"${normalColor}
else
    echo -e ${purpleColor}"Install ZEN from source\n"${normalColor}
fi

################################################################# packages #############################################
sudo apt-get update
sudo apt -y install pwgen
sudo apt-get install git -y
sudo apt -y install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

################################################################ basic security ########################################
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow http/tcp
sudo ufw allow https/tcp
sudo ufw allow 9033/tcp
sudo ufw allow 19033/tcp
sudo ufw logging on
sudo ufw --force enable
echo -e ${purpleColor}"Basic security completed!"${normalColor}

################################################################# Add a swapfile. ######################################
if [ $(cat /proc/swaps | wc -l) -eq 2 ]; then
  echo "Configuring your swapfile..."
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
else
  echo "Swapfile exists. Skipping."
fi
echo -e ${purpleColor}"Swapfile is done!"${normalColor}

#################################### Create an empty zen config file and add new config settings. ######################
if [ -f /$USER/.zen/zen.conf ]; then
  sudo rm /$USER/.zen/zen.conf || true
fi
echo "Creating an empty ZenCash config..."
sudo mkdir -p /$USER/.zen || true
sudo touch /$USER/.zen/zen.conf

RPC_USERNAME=$(pwgen -s 16 1)
RPC_PASSWORD=$(pwgen -s 64 1)

sudo sh -c "echo '
addnode=$HOST_NAME
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
tlscertpath=/$USER/.acme.sh/$HOST_NAME/$HOST_NAME.cer
tlskeypath=/$USER/.acme.sh/$HOST_NAME/$HOST_NAME.key
### testnet config
# testnet=1
' >> /$USER/.zen/zen.conf"

echo -e ${purpleColor}"zen.conf is done!"${normalColor}


############################################################### ssl-certificate: #######################################
if [ ! -d /$USER/acme.sh ]; then
  sudo apt install socat
  cd /$USER && git clone https://github.com/Neilpang/acme.sh.git
  cd /$USER/acme.sh && sudo ./acme.sh --install
  sudo chown -R $USER:$USER /$USER/.acme.sh
fi
if [ ! -f /$USER/.acme.sh/$HOST_NAME/ca.cer ]; then
  sudo /$USER/.acme.sh/acme.sh --issue --standalone -d $HOST_NAME
fi
cd ~
sudo cp /$USER/.acme.sh/$HOST_NAME/ca.cer /usr/local/share/ca-certificates/$HOST_NAME.crt
sudo update-ca-certificates
CRONCMD_ACME="6 0 * * * \"/$USER/.acme.sh\"/acme.sh --cron --home \"/$USER/.acme.sh\" > /dev/null" && (crontab -l | grep -v -F "$CRONCMD_ACME" ; echo "$CRONCMD_ACME") | crontab -
echo -e ${purpleColor}"certificates has been installed!"${normalColor}


############################################################ Installing zen: ###########################################
case $ZEN_INSTALL_CHOICE in
  1)
     echo "BUILD FROM REPO:"
     if ! [ -x "$(command -v zend)" ]; then
       sudo apt-get install apt-transport-https lsb-release -y
       echo 'deb https://zencashofficial.github.io/repo/ '$(lsb_release -cs)' main' | sudo tee --append /etc/apt/sources.list.d/zen.list
       gpg --keyserver ha.pool.sks-keyservers.net --recv 219F55740BBF7A1CE368BA45FB7053CE4991B669
       gpg --export 219F55740BBF7A1CE368BA45FB7053CE4991B669 | sudo apt-key add -

       sudo apt-get update
       sudo apt-get install zen -y

       sudo chown -R $USER:$USER /$USER/.zen
       zend
       zen-fetch-params
     fi
  ;;
  2)
    echo "BUILD FROM SOURCE:"
    if ! [ -x "$(command -v /$USER/zen/src/zend)" ]; then
      # Clone ZenCash from Git repo.
      if [ -d /$USER/zen ]; then
        sudo rm -r /$USER/zen
      fi
      echo "Downloading ZenCash source..."
      git clone https://github.com/ZencashOfficial/zen.git

      # Download proving keys.
      if [ ! -f /$USER/.zcash-params/sprout-proving.key ]; then
        echo "Downloading ZenCash keys..."
        sudo /$USER/zen/zcutil/fetch-params.sh
      fi

      # Compile source.
      echo -e ${purpleColor}"Compiling ZenCash..."${normalColor}
      cd /$USER/zen && ./zcutil/build.sh -j$(nproc)
      sudo chown -R $USER:$USER /$USER/.zen

      # copy executable to the bin directory.
      sudo cp /$USER/zen/src/zend /usr/bin/
      sudo cp /$USER/zen/src/zen-cli /usr/bin/
    fi
  ;;
  *)
    echo "Invalid choice to install zen. Re-run the script!"
    exit 1
  ;;
esac


# Create a shielded address on the zen node:
zen-cli z_getnewaddress
zen-cli z_listaddresses

echo -e ${purpleColor}"zen installation is finished!"${normalColor}


########################################### run znode and sync chain on startup of VM: #################################
CRONCMD="@reboot /usr/bin/zend" && (crontab -l | grep -v -F "$CRONCMD" ; echo "$CRONCMD") | crontab -

####################################################### secnodetracker #################################################
sudo apt -y install npm
sudo npm install -g n
sudo n latest
sudo npm install pm2 -g
if [ ! -d /$USER/secnodetracker ]; then
  cd /$USER && git clone https://github.com/ZencashOfficial/secnodetracker.git
  cd /$USER/secnodetracker && npm install
fi
echo -e ${purpleColor}"secnodetracker added!"${normalColor}

cd secnodetracker && node setup.js
node app.js


#################################################### Useful commands ###################################################
zenecho ""
echo ""
echo "Now type \"~/zen/src/zend\" or \"zend\" to launch ZenCash!"
echo "\n"
echo "Check totalbalance: zen-cli z_gettotalbalance"
echo "\n"
echo "Get new address: zen-cli z_getnewaddress"
echo "\n"
echo "List all addresses: zen-cli z_listaddresses"
echo "\n"
echo "Get network info: zen-cli getnetworkinfo. Make sure 'tls_cert_verified' is true."
echo "\n"
echo "###############################################################################################################"
echo "\n"
echo "Deposit 5 x 0.2 ZEN in private address within VPS"
echo "\n"
echo "Run app from /$USER/secnodetracker/ directory: \"node setup.js\" and \"node app.js\""
echo "\n"
echo "ALL DONE! "
echo ""
echo ""

