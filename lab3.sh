#!/bin/bash
# This script runs the configure-host.sh script from the current directory
# to modify 2 servers and update the local /etc/hosts file

# Check if verbose mode is enabled
VERBOSE=false
if [[ "$1" == "-verbose" ]]; then
  VERBOSE=true
  shift
fi

# Transfer the configure-host.sh script to the servers
scp configure-host.sh remoteadmin@server1-mgmt:/root
scp configure-host.sh remoteadmin@server2-mgmt:/root

# Run the configure-host.sh script on server1
if $VERBOSE; then
  ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 -verbose
else
  ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4
fi

# Run the configure-host.sh script on server2
if $VERBOSE; then
  ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 -verbose
else
  ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3
fi

# Update the local /etc/hosts file
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
