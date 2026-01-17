# sock-shop-kubernetes-devops
sock-shop-kubernetes-devops
# Sock Shop Microservices – AWS DevOps Project

## Overview
This project demonstrates an end-to-end DevOps implementation for deploying
a microservices-based application on AWS using Terraform, Ansible, Jenkins,
and Kubernetes.

## Architecture
- AWS VPC with public and private subnets
- Highly available Kubernetes cluster
- HAProxy with Keepalived for failover
- CI/CD pipeline using Jenkins
- Infrastructure provisioned using Terraform

![Architecture Diagram](architecture/architecture-diagram.png)

## Technologies Used
- AWS (EC2, VPC, ALB, ASG, S3)
- Terraform
- Ansible
- Jenkins
- Kubernetes
- Docker / containerd
- HAProxy & Keepalived

## Repository Structure
See the folder structure above for clear separation of concerns:
- terraform/ – Infrastructure provisioning
- ansible/ – Configuration management
- kubernetes/ – Application manifests
- jenkins/ – CI/CD pipeline
- docs/ – Architecture & failure documentation

## How to Deploy
1. Provision infrastructure using Terraform
2. Configure servers using Ansible
3. Bootstrap Kubernetes cluster
4. Deploy Sock Shop microservices
5. Access application via Load Balancer

## Author
Inalegwu J Aleyi
