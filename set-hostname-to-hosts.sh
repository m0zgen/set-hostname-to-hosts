#!/bin/bash
# Created by Yevgeniy Goncharov, https://lab.sys-adm.in
# Update the /etc/hosts file to include the current hostname
# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

# Variables
# -------------------------------------------------------------------------------------------\

# Define the user's home directory
user_home=$(eval echo "~$(whoami)")

# Get the hostname from the /etc/hostname file
hostname=$(cat /etc/hostname)

# Get the first octet of the hostname
first_octet=$(echo $hostname | cut -d'.' -f1)

# Standard 127.0.0.1 localhost entry
standard_entry="127.0.0.1\tlocalhost"

# Create a new entry to add to the /etc/hosts file
new_entry="127.0.1.1\t$hostname $first_octet"

# Backup directory path
backup_dir="$SCRIPT_PATH/hosts_backup"

# Bool variable if changes are made
changes_made=false

# Main
# -------------------------------------------------------------------------------------------\

echo -e "\nProcessing the /etc/hosts file...\n"

# Function create backup dir in script dir
function create_backup_dir() {
    # Create the backup directory if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        echo -e "Creating the backup directory at $user_home/hosts_backup"
        mkdir $backup_dir
    fi
}

# Backup the /etc/hosts file function
function backup_hosts_file() {

    # Define the backup file path with current date and time
    local backup_file="$backup_dir/hosts_backup_$(date +'%Y%m%d_%H%M%S')"
    sleep 1
    # Check if the backup directory exists
    create_backup_dir

    # Backup the /etc/hosts file
    echo -e "Backing up the /etc/hosts file to $backup_file"
    cp /etc/hosts $backup_file
}

# Function remove double entries
function remove_double_entries() {
    
    if awk '!seen[$0]++' /etc/hosts | grep -qE "127.0.0.1|127.0.1.1"; then
        # Remove double entries from the /etc/hosts file
        echo -e "Removing double entries from the /etc/hosts file"
        backup_hosts_file
        
        # If double entries are found, remove them
        awk '!seen[$0]++' /etc/hosts > /etc/hosts.tmp && mv /etc/hosts.tmp /etc/hosts
        changes_made=true
    fi
}

# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.0.1" /etc/hosts; then
    # Add as first line the standard entry to the /etc/hosts file
    echo -e "127.0.0.1 not found in /etc/hosts file, adding it now"
    backup_hosts_file
    sed -i "1i 127.0.0.1\tlocalhost" /etc/hosts
    changes_made=true
fi

# Check if the entry already exists in the /etc/hosts file
if grep -q "^127.0.1.1" /etc/hosts; then
    # Remove the entry from the /etc/hosts file
    echo -e "Found 127.0.1.1 entry in /etc/hosts file. Removing..."
    echo -e "Removing the old 127.0.1.1 entry from /etc/hosts file"
    backup_hosts_file
    sed -i "/^127.0.1.1/d" /etc/hosts
    changes_made=true
fi

# Secondary check if the entry already exists
# Check if the entry already exists in the /etc/hosts file
if ! grep -q "^127.0.1.1" /etc/hosts; then
    # Add the new entry to the /etc/hosts file
    echo -e "Adding the new entry: $new_entry to /etc/hosts file after the standard entry"
    backup_hosts_file
    sed -i "/^127.0.0.1/a $new_entry" /etc/hosts
    changes_made=true
fi

# Remove double entries from the /etc/hosts file
remove_double_entries

# Check if changes were made
if [ "$changes_made" = "true" ]; then
    # Print the changes made
    echo -e "\nChanges made to the /etc/hosts file:\n"
    cat /etc/hosts

    echo -e "\nBackup of the /etc/hosts file was created in $backup_dir\n"
else
    # Print that no changes were made
    echo -e "\nNo changes were made to the /etc/hosts file"
fi