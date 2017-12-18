#!/usr/bin/env bash


# Copy wallet to VPS
scp ./wallets/${NODE}_wallet.dat ${NODE}:/root/.zen/

# Show number of blocks
echo -e "Synced # of blocks: "`zen-cli getblockcount`




# Others
zen-cli getpeerinfo
zen-cli getnetworkinfo
zen-cli getinfo
zen-cli z_listaddresses



zen-cli getnetworkinfo
zen-cli z_gettotalbalance
echo -e "Synced # of blocks: "`zen-cli getblockcount`



zen-cli


crontab -e

@reboot /usr/bin/zend
@reboot cd /root/secnodetracker/ && /usr/local/bin/node app.js &


tail -f /proc/<pid>/fd/1