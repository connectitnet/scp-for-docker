#!/bin/bash

# This won't be executed if keys already exist (i.e. from a volume)
ssh-keygen -A

# Loop through SCP_USERS and add them if they don't already exist
IFS=, read -ra users <<< "$SCP_USERS"
COUNTER=0
for username in "${users[@]}"
do
    id -u $username &>/dev/null || adduser -D -u 100$COUNTER -H -s /usr/bin/rssh $username
    mkdir -p /home/$username/.ssh
    chmod 0700 /home/$username
    touch /home/$username/.ssh/authorized_keys 
    chmod 0600 /home/$username/.ssh/authorized_keys
    
    # Chown home folder (if mounted as a volume for the first time)
    chown -R $username:$username /home/$username

    COUNTER=$COUNTER+1
done

# Copy authorized keys from ENV variable
echo $AUTHORIZED_KEYS | base64 -d >> $AUTHORIZED_KEYS_FILE

# Run sshd on container start
exec /usr/sbin/sshd -D -e