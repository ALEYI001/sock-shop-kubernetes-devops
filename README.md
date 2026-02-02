<<<<<<< HEAD
#Sock-Shop-Kubernetes-Project-Using-Ansible
#Detailing The Business and Technical Overview

**Enterprise Cloud Platform for Scalable E-Commerce Microservices**
**Executive Summary**

This project delivers a production-ready cloud platform designed to help a retail client deploy, scale, and operate a modern microservices-based e-commerce application securely and reliably on AWS.

The solution addresses the clients business challenges such as high availability, traffic surges, deployment consistency, operational resilience, and security, using proven DevOps and cloud-native technologies.# sock-shop-kubernetes-devops
sock-shop-kubernetes-devops

**Business Problem**

The client requires a platform that can:

Handle unpredictable customer traffic without downtime

Deploy application changes quickly and safely

Recover automatically from infrastructure or application failures

Maintain strong security and network isolation

Scale without manual intervention(still been looked into, but much more along the lines of **_KEDA_**)

Traditional monolithic architectures and manual deployments were unable to meet these requirements reliably.

******************************************************************************************************************
**Solution Overview**

This platform implements a highly available, automated, and secure cloud architecture using Infrastructure as Code, CI/CD pipelines, and Kubernetes orchestration.

Key outcomes include:

Zero-downtime deployments

Automated infrastructure provisioning

Self-healing application workloads

Built-in availability and fault tolerance

***************************************************************************************************************************

**High-Level Architecture**

The solution is deployed on AWS using a multi–Availability Zone design to eliminate single points of failure.

Core Components

AWS VPC with public and private subnets

Application Load Balancer for inbound traffic

HAProxy with Keepalived for internal traffic routing and failover

Kubernetes cluster for container orchestration

Terraform for infrastructure provisioning

Ansible for configuration management

Jenkins for CI/CD automation

Chekov for vulnerabilities and misconfigurations scan

OWASP ZAP for security validation
***********************************************************************************

**Platform Capabilities**

_**High Availability & Fault Tolerance**_

Multi-AZ deployment across three Availability Zones

Automatic HAProxy failover using a Virtual IP

Kubernetes self-healing for pods and nodes

**_Scalability_**
_NOTE:_ The current architecture is scalability-capable, but only sparingly scalability-implemented.

That is, at present, scalability is enabled at the Kubernetes application layer through replication and load balancing at multiple layer. However, automatic scaling requires explicit configuration via Horizontal Pod Autoscalers and node autoscaling, which can be activated using Kubernetes metrics and AWS Auto Scaling Groups. This demonstrates a scalable-ready design, with clear extension points for full elasticity. Particularly, with the full monitoring and observability implemented via Prometheus and Grafana, the best bet for auto-scaloing may just be _*KEDA*_.

**_Security_**

Private subnets for all compute resources

Controlled access via bastion patterns

Integrated security scanning in the CI/CD pipeline

Least-privilege IAM roles

**_Automation & Delivery_**

Fully automated infrastructure provisioning

CI/CD pipelines for build, test, and deployment

Environment consistency across deployments

************************************************************************************************

**_Deployment Workflow (Client View)_**

Infrastructure is provisioned automatically using Terraform

Servers are configured consistently using Ansible

Kubernetes cluster is bootstrapped

Microservices are deployed via CI/CD pipeline

Monitoring and security validation are applied continuously

This workflow reduces deployment risk and accelerates delivery timelines.

_**Business Value Delivered**_

Improved customer experience through high availability

Reduced operational overhead via automation

Faster time-to-market with CI/CD

Lower risk through proactive security checks

Future-ready platform capable of growth



## Techical Overview and project flow chart
This project demonstrates an end-to-end DevOps implementation for deploying
a microservices-based application on AWS using Terraform, Ansible, Jenkins,
and Kubernetes.

## Architecture
- AWS VPC with public and private subnets
- Highly available Kubernetes cluster
- HAProxy with Keepalived for failover
- CI/CD pipeline using Jenkins
- Infrastructure provisioned using Terraform

![Architecture Diagram]: https://cloudhight.slack.com/files/U09E0QBCTKQ/F0A5KK0LA48/image.png

## Technologies Used
- AWS (EC2, VPC, ALB, ASG, S3)
- Terraform
- Ansible
- Jenkins
- Kubernetes
- Docker / containerd
- HAProxy & Keepalived

## Justification For Architectural Design
To view the documentation on justification for the architectural design view below: the word document requires a download whilst the pdf can be viewed direclty
[![PDF](https://img.shields.io/badge/Documentation-PDF-red)](./docs/Architecture%20Justification%20Document.pdf)

[![Word Doc](https://img.shields.io/badge/Documentation-Word-blue)](./docs/Architecture%20Justification%20Document.docx)

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

## Challenges and Solutions
To view the documentation of the challenges encountered and solutions proferred, click link below:the word document requires a download whilst the pdf can be viewed direclty
[![Word Doc](https://img.shields.io/badge/Documentation-PDF-red)](./docs/Final%20Project%20Challenges%20and%20Solutions.pdf)

[![Word Doc](https://img.shields.io/badge/Documentation-Word-blue)](./docs/Final%20Project%20Challenges%20and%20Solutions.docx)

## Author
Inalegwu J Aleyi
>>>>>>>
