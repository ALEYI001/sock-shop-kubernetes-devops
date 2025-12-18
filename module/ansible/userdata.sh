#!/bin/bash

# Update instance and install ansible
sudo apt-get update -y
sudo apt-get install unzip -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y
sudo bash -c 'echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config'

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

# pulling playbook from s3 bucket
aws s3 cp s3://"${s3_bucket_name}"/playbooks /etc/ansible/playbooks --recursive


#updating hosts file
echo "[main-master]" > /etc/ansible/hosts
echo "${master1_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "[member-master]" >> /etc/ansible/hosts
echo "${master2_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "${master3_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "[worker-nodes]" >> /etc/ansible/hosts
echo "${worker1_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "${worker2_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "${worker3_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "[haproxy-1]" >> /etc/ansible/hosts
echo "${haproxy1_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts
echo "[haproxy-2]" >> /etc/ansible/hosts
echo "${haproxy2_private_ip} ansible_user=ubuntu" >> /etc/ansible/hosts

# create haproxy group vars file
echo "haproxy_1: ${haproxy1_private_ip}" > /etc/ansible/haproxy.yml
echo "haproxy_2: ${haproxy2_private_ip}" >> /etc/ansible/haproxy.yml
sudo chown -R ubuntu:ubuntu /etc/ansible/

# # Run ansible playbook to setup kubernetes cluster
sudo su -c "ansible-playbook /etc/ansible/playbooks/installation.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/keepalived.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/main-master.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/join-nodes.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/kubectl.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/stage.yml" ubuntu
# sudo su -c "ansible-playbook /etc/ansible/playbooks/prod.yml" ubuntu
sudo su -c "ansible-playbook /etc/ansible/playbooks/monitoring.yml" ubuntu

# Set hostname
sudo hostnamectl set-hostname ansible