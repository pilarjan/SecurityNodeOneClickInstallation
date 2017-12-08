#!/usr/bin/env bash

MAIL=
DOMAIN=
HOST=$(hostname -f)
HOST_NAME=${HOST}.${DOMAIN}
FQDN=${HOST_NAME}
USER=$(whoami)
IPv=4
REGION=eu
# zen installation method:
# DEFAULT="1"
# read -p "Enter 1 to build ZEN from repo; enter 2 to build from source: (default 1)" ZEN_INSTALL_CHOICE
# ZEN_INSTALL_CHOICE="${ZEN_INSTALL_CHOICE:-${DEFAULT}}"
ZEN_INSTALL_CHOICE=1

purpleColor='\033[0;95m'
normalColor='\033[0m'
echo -e ${purpleColor}"---------------------------------------------------------------------------------"
echo -e ${purpleColor}"Host: $HOST"
echo -e ${purpleColor}"Email: $MAIL"
echo -e ${purpleColor}"Domain: $DOMAIN"
echo -e ${purpleColor}"Host name: $HOST_NAME"
echo -e ${purpleColor}"FQDN: $FQDN"
echo -e ${purpleColor}"IP version: $IPv"
echo -e ${purpleColor}"Region: $REGION"
if [ "${ZEN_INSTALL_CHOICE}" -eq "1" ]; then
    echo -e ${purpleColor}"Install ZEN from: repository (default)"
else
    echo -e ${purpleColor}"Install ZEN from: source"
fi
echo -e ${purpleColor}"---------------------------------------------------------------------------------"${normalColor}

T_ADDRESS_000=
T_ADDRESS_001=
T_ADDRESS_002=
T_ADDRESS_003=
T_ADDRESS_004=


echo "Loading from my_config.sh has been finished!"
