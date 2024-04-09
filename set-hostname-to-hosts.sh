#!/bin/bash
# Created by Yevgeniy Goncharov, https://lab.sys-adm.in
# Update the /etc/hosts file to include the current hostname
# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

# Variables
# -------------------------------------------------------------------------------------------\

# Get the hostname from the /etc/hostname file
hostname=$(cat /etc/hostname)

# Get the first octet of the hostname
first_octet=$(echo $hostname | cut -d'.' -f1)

# Standard 127.0.0.1 localhost entry
standard_entry="127.0.0.1\tlocalhost"

# Create a new entry to add to the /etc/hosts file
new_entry="127.0.1.1\t$hostname $first_octet"

# Bool variable if changes are made
changes_made=false

# Main
# -------------------------------------------------------------------------------------------\

# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.0.1" /etc/hosts; then
    # Add as first line the standard entry to the /etc/hosts file
    echo -e "127.0.0.1 not found in /etc/hosts file, adding it now"
    sed -i "1i 127.0.0.1\tlocalhost" /etc/hosts
    changes_made=true
fi

# Check if the entry already exists in the /etc/hosts file
if grep -q "^127.0.1.1" /etc/hosts; then
    # Remove the entry from the /etc/hosts file
    echo -e "Removing the old 127.0.1.1 entry from /etc/hosts file"
    sed -i "/^127.0.1.1/d" /etc/hosts
    changes_made=true
fi

# Secondary check if the entry already exists
# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.1.1" /etc/hosts; then
    # Add the new entry to the /etc/hosts file
    echo -e "Adding the new entry: $new_entry to /etc/hosts file after the standard entry"
    sed -i "/^127.0.0.1/a $new_entry" /etc/hosts
    changes_made=true
fi

# Check if changes were made
if [ "$changes_made" = "true" ]; then
    # Print the changes made
    echo -e "Changes made to the /etc/hosts file:"
    cat /etc/hosts
else
    # Print that no changes were made
    echo -e "No changes were made to the /etc/hosts file"
fi