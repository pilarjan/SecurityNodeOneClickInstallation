#!/usr/bin/env bash


t_address_sender='your t-address'
t_address_receiver='receivers t-address'
fee=0.0001
min_confirmations=1
amount=XXXX
zen-cli z_sendmany ${t_address_sender} "[{\"address\": \"$t_address_receiver\", \"amount\": $amount, \"minconf\": $min_confirmations, \"fee\": $fee}]"
