#!/usr/bin/env bash

NODE_START=0
NODE_STOP=175

function batch {
    echo "NODE:" $1
    scp root@${1}:/root/.zen/wallet.dat ~/PycharmProjects/SecurityNodeOneClickInstallation/wallets/${1}_wallet.dat
}

for NODE in {${NODE_START}..${NODE_STOP}}
do
    if [ ${NODE} -lt 10 ]; then
        batch 00${NODE}
    elif [ ${NODE} -lt 100 ]; then
        batch 0${NODE}
    else
        batch ${NODE}
    fi
done
