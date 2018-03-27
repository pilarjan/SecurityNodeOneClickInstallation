#!/usr/bin/env bash

FILE_NAME="z_balance_27_3_2018.txt"

function batch {
    echo "NODE:" $1
    echo -n $1 >> z_balance.txt ; ssh $1 "zen-cli z_gettotalbalance | grep total" >> $2
}

for NODE in {0..184}
do
    if [ ${NODE} -lt 10 ]; then
        batch 00${NODE} ${FILE_NAME}
    elif [ ${NODE} -lt 100 ]; then
        batch 0${NODE} ${FILE_NAME}
    else
        batch ${NODE} ${FILE_NAME}
    fi
done

