#!/usr/bin/env bash


# -------------------------------------- PERSONAL - SETTINGS -----------------------------------------------------------
MAIL=your@email
# If SSL_CERTIFICATE_CHOICE=1, you have to set this:
CERT="cert.crt"
CERT_KEY="my_key.key"
CA="CA.crt"

# -------------------------------------- GENERAL - SETTINGS ------------------------------------------------------------
HOST_NAME=$(hostname -f)
FQDN=${HOST_NAME}
USER=$(whoami)
IPv=4
REGION=eu
# zen installation method:
# DEFAULT="1"
# read -p "Enter 1 to build ZEN from repo; enter 2 to build from source: (default 1)" ZEN_INSTALL_CHOICE
# ZEN_INSTALL_CHOICE="${ZEN_INSTALL_CHOICE:-${DEFAULT}}"
ZEN_INSTALL_CHOICE=1

# I am using my own wildcard certificate = 1, free letsencrypt = 2
SSL_CERTIFICATE_CHOICE=1

# -------------------------------------- PRINT - OF - SETTINGS ---------------------------------------------------------
purpleColor='\033[0;95m'
normalColor='\033[0m'
echo -e ${purpleColor}"---------------------------------------------------------------------------------"
# echo -e ${purpleColor}"Host: $HOST"
echo -e ${purpleColor}"Email: $MAIL"
# echo -e ${purpleColor}"Domain: $DOMAIN"
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

# -------------------------------------- LIST - OF - T-ADDRESSESS ------------------------------------------------------
# Set these your staking addresses here
# T_ADDRESS_000=
# T_ADDRESS_001=
# T_ADDRESS_002=
# T_ADDRESS_003=
# T_ADDRESS_004=
# ETC ...

echo "Loading from my_config.sh has been finished!"
