#!/bin/bash

# Exit if any command fails
set -e

# Function to log changes
log_change() {
    logger "configure-host.sh: $1"
}

# Ignore TERM, HUP, and INT signals
trap '' TERM HUP INT

# Process command line arguments
VERBOSE=false
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -verbose)
            VERBOSE=true
            ;;
        -name)
            HOSTNAME="$2"
            shift
            ;;
        -ip)
            IPADDRESS="$2"
            shift
            ;;
        -hostentry)
            HOSTNAME_ENTRY="$2"
            IPENTRY="$3"
            shift 2
            ;;
    esac
    shift
done

# Set hostname if necessary
if [ "$HOSTNAME" ]; then
    CURRENT_HOSTNAME=$(cat /etc/hostname)
    if [ "$CURRENT_HOSTNAME" != "$HOSTNAME" ]; then
        echo "$HOSTNAME" > /etc/hostname
        hostnamectl set-hostname "$HOSTNAME"
        log_change "Changed hostname to $HOSTNAME"
        if [ "$VERBOSE" = true ]; then
            echo "Changed hostname to $HOSTNAME"
        fi
    fi
fi

# Set IP address if necessary
# Set IP address if necessary
if [ "$IPADDRESS" ]; then
    CURRENT_IPADDRESS=$(hostname -I | awk '{print $1}')
    if [ "$CURRENT_IPADDRESS" != "$IPADDRESS" ]; then
        # Update Netplan configuration
        echo "Updating IP to $IPADDRESS"
        # Add your netplan modification logic here
        log_change "Changed IP address to $IPADDRESS"
        if [ "$VERBOSE" = true ]; then
            echo "Changed IP address to $IPADDRESS"
        fi
    fi
fi

# Set host entry
if [ "$HOSTNAME_ENTRY" ] && [ "$IPENTRY" ]; then
    grep -q "$HOSTNAME_ENTRY" /etc/hosts
    if [ $? -ne 0 ]; then
        echo "$IPENTRY $HOSTNAME_ENTRY" >> /etc/hosts
        log_change "Added $HOSTNAME_ENTRY with IP $IPENTRY to /etc/hosts"
        if [ "$VERBOSE" = true ]; then
            echo "Added $HOSTNAME_ENTRY with IP $IPENTRY to /etc/hosts"
        fi
    fi
fi

