#!/bin/bash
# Created by Yevgeniy Goncharov, https://lab.sys-adm.in
# Update the /etc/hosts file to include the current hostname

# Get the hostname from the /etc/hostname file
hostname=$(cat /etc/hostname)

# Get the first octet of the hostname
first_octet=$(echo $hostname | cut -d'.' -f1)

# Standard 127.0.0.1 localhost entry
standard_entry="127.0.0.1\tlocalhost"

# Create a new entry to add to the /etc/hosts file
new_entry="127.0.1.1\t$hostname $first_octet"

# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.0.1" /etc/hosts; then
    # Add as first line the standard entry to the /etc/hosts file
    sed -i "1i 127.0.0.1\tlocalhost" /etc/hosts
fi

# Check if the entry already exists in the /etc/hosts file
if grep -q "^127.0.1.1" /etc/hosts; then
    # Если строка существует, удаляем ее
    sed -i "/^127.0.1.1/d" /etc/hosts
fi

# Secondary check if the entry already exists
# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.1.1" /etc/hosts; then
    # Add the new entry to the /etc/hosts file
    sed -i "/^127.0.0.1/a $new_entry" /etc/hosts
fi
