# ☁️ Enterprise Multi-VPC Peered Network with Bastion Jump Security

![AWS Certified](https://img.shields.io/badge/AWS-Certified%20Solutions%20Architect-FF9900?logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/IaC-Terraform%20v1.5+-7B42BC?logo=terraform&logoColor=white)
![Status](https://img.shields.io/badge/Verification-0%25%20Packet%20Loss-10B981?logo=checkmarx)

A production-grade implementation of an enterprise multi-tier AWS network topology built for the **EWB Tech Academy AWS Cloud & AI Internship Final Capstone Project**.

## Architecture & Traffic Flow
- **VPC 1 (28.0.0.0/16)**:
  - Subnet 1 (28.0.1.0/24, Public): IGW + Bastion Jump Host (EC2-1)
  - Subnet 2 (28.0.2.0/24, Private): Internal Application Server (EC2-2)
- **VPC 2 (28.200.0.0/16)**:
  - Subnet 3 (28.200.0.0/16, Private): Isolated Target Server (EC2-3)
- **Peering Link**: Direct bidirectional AWS VPC Peering connection (pcx-xxxx).
- **Access Rule**: External clients can only SSH into EC2-1. EC2-2 and EC2-3 can only be accessed through EC2-1 via agent forwarding.

## Quickstart
1. terraform init
2. terraform plan
3. terraform apply -auto-approve
