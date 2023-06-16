#!/bin/bash
set -euo pipefail

### Variables

# Name of the user to create and grant sudo privileges
USERNAME=mateo

# Whether to copy over the root `authorized_keys` file to the new user
COPY_AUTHORIZED_KEYS_FROM_ROOT=true

# Script

# Install Docker and Docker Compose
apt-get update 
# Install needed packages
apt-get install ca-certificates curl gnupg lsb-release
# Add Docker’s official GPG key 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Set up the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update the apt package index
apt-get update
# Install Docker and Docker Compose latest version
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Install ssmtp to email cron job results 
apt-get install -y ssmtp

# Lock the root account to password-based access
passwd --lock root

# Add sudo user and grant privileges
useradd --create-home --shell "/bin/bash" --groups sudo,docker $USERNAME

# Remove the user's password so that a new password can be set without suppling a previous one
passwd --delete $USERNAME

# Expire the user's password immediately to force a change
chage --lastday 0 $USERNAME

# Create SSH directory for sudo user
home_directory=$(eval echo ~$USERNAME)
mkdir --parents $home_directory/.ssh

# Copy `authorized_keys` file from root
if [ $COPY_AUTHORIZED_KEYS_FROM_ROOT = true ]; then
    cp /root/.ssh/authorized_keys $home_directory/.ssh
fi

# Create an ssh key pair for remote (GitHub) validation
ssh-keygen -f $home_directory/.ssh/id_rsa -q -N ""

# Add and verify GitHub in the known_hosts list
ssh-keyscan github.com >> $home_directory/.ssh/known_hosts

# Adjust SSH configuration ownership and permissions
chmod 0700 $home_directory/.ssh
chmod 0600 $home_directory/.ssh/authorized_keys
chown --recursive $USERNAME:$USERNAME $home_directory/.ssh

# Add exception for SSH and then enable UFW firewall
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw --force enable
