#!/usr/bin/env bash

# -------------------------------------------------------------------------------------
# NOTE! : fill MAIL and DOMAIN variables and rename this file to my_config.sh and save
# -------------------------------------------------------------------------------------

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

echo ${HOST}
echo ${MAIL}
echo ${DOMAIN}
echo ${HOST_NAME}
echo ${FQDN}
echo ${USER}
echo ${IPv}
echo ${REGION}
echo ${ZEN_INSTALL_CHOICE}

T_ADDRESS_000=
T_ADDRESS_001=
T_ADDRESS_002=
T_ADDRESS_003=
T_ADDRESS_004=
T_ADDRESS_005=
T_ADDRESS_006=
T_ADDRESS_007=
T_ADDRESS_008=
T_ADDRESS_009=

echo "Loading from my_config.sh has been finished!"
