Hello friends,

This is the detailed guide to setup secure node over zencash. I am using Linode 2048 (Fremont, CA, USA) - Ubuntu 16.04 LTS instance to run this node. Assign ip, a DNS name from your service provider. eg. godaddy.

Part 1: Add user and Run the script:
Add user: adduser <username> && adduser <username> sudo

Login with newly created user and run this script from /home/<USER>/ directory. Command you need to use is: bash -c "$(curl SCRIPT_URL)". To get SCRIPT_URL click raw on below github link and copy the URL from top.

https://gist.github.com/rnkhouse/f7f04f0cb10b596e2c6623275968a220

While executing the script you will be prompt for host name where you can enter your host name (a.example.com).

Type ~/zen/src/zend or zend to launch ZenCash!
Part 2: Node tracker:
Now the node is up and running. Deposit 5 x 0.2 ZEN or 4 x 0.25 ZEN in private address within your VM from swing wallet. After that run app from /home/<username>/secnodetracker/ directory:

node setup.js
node app.js
Part 3: Automation and Monitoring the tracking application:
To run the app in background:

pm2 start /home/$USER/secnodetracker/app.js --name securenodetracker
To run the app on VM startup automatically:

pm2 startup
This will then give you a command line that you need to execute to complete the configuration of the daemon for system bootup.

Monitoring of the securenodetracker service is done by running the following command:

pm2 logs securenodetracker
pm2 monit
To check the status of the service you can run:

pm2 status securenodetracker
Stopping the securenodetracker service is just an easy as running the following command:

pm2 stop securenodetracker
Log file location: .pm2/logs

Important commands:
Check totalbalance: zen-cli z_gettotalbalance
Get new address: zen-cli z_getnewaddress
List all addresses: zen-cli z_listaddresses
Get network info: zen-cli getnetworkinfo. Make sure tls_cert_verified is true.
Chain info: zen-cli getinfo
Stop ZEN: zen-cli stop
Donations:
ZEN: znTAPuMXxxvZn2Wj6uHMpqPUTESzrsrSeik
ETH: 0xbe29278ebf4f714d78682ad3344c8034644c1805
BTC: 1sHyTAZw9HMWGgWZioop2mbKa3YnC7mja

Initiate transaction from your VM:
If you want to send ZEN back to swing wallet from your VM use below command. This one will be useful if you want to close that node.

zen-cli z_sendmany "FROM_ZEN_ADDR" "[{\"amount\": 0.25, \"address\": \"TO_ZEN_ADDR\"}]"
Support:
I am on Zencash slack: zencash.slack.com. Username: rnkhouse. Or just comment here.