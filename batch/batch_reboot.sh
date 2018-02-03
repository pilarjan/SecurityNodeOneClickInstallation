#!/usr/bin/env bash

NODE_START=0
NODE_STOP=175

function batch {
    echo "NODE:" $1
#    ssh $1 "reboot now"
    ssh $1 "sudo apt-get update && apt-get upgrade -y && apt-get autoremove -y && reboot now"
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
    sleep 60s
done

