#!/bin/bash
apt-get update -y

# Copy the private key into the .ssh directory
echo "${private_key}" > /home/ubuntu/.ssh/id_rsa
# Set correct permissions and ownership
chmod 400 /home/ubuntu/.ssh/id_rsa
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

# Set hostname
hostnamectl set-hostname bastion