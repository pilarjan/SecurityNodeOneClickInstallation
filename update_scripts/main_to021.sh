#!/usr/bin/env bash

purpleColor="\033[0;95m"
normalColor="\033[0m"
NODE_START=0
NODE_STOP=175


function batch {
    echo -e ${purpleColor} "Node:" $1 ${normalColor}
    date
#    echo -e ${purpleColor} date ${normalColor}
#    echo "Node:" $1 "| time:" date
    ssh $1 "bash -s" < secnodetracker_to021.sh
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

    secs=$((60))
    while [ ${secs} -gt 0 ]; do
        echo -ne ${purpleColor} "NODE="${NODE}": $secs\033[0K\r" ${normalColor}
       sleep 1
       : $((secs--))
    done
done