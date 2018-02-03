#!/usr/bin/env bash

NODE_START=0
NODE_STOP=175

function batch {
    MINUTE=$[ ( $RANDOM % 60 ) ]
    echo "Node:" $1 "| Minute:" ${MINUTE}
    ssh $1 "crontab -l | { cat; echo \"$MINUTE */1 * * * /usr/bin/pkill -f secnodetracker\"; } | crontab -"
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
