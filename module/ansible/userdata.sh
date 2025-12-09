#!/bin/bash

# Update instance and install ansible
sudo apt-get update -y
sudo apt-get install unzip -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y

# Installing awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip
rm -rf aws/
sudo ln -svf /usr/local/bin/aws /usr/bin/aws

# Copy private key
echo "${private_key}" > /home/ubuntu/.ssh/id_rsa 
sudo chmod 400 /home/ubuntu/.ssh/id_rsa
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

# Set hostname
sudo hostnamectl set-hostname ansible