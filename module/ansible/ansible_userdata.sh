#!/bin/bash

#!/bin/bash

# Updating the system and installing necessary packages

echo "--- Installing dependencies ---"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip git jq curl wget vim unzip

# --- Upgrade pip and install Ansible 2.15+ ---
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install "ansible>=2.15" boto3 botocore

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


sudo hostnamectl set-hostname ansible
