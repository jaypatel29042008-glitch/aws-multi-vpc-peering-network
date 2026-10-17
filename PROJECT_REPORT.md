# 📄 EWB Tech Academy Capstone Project Report
## Enterprise Multi-VPC Peered Network with Bastion Jump Security & Isolated Workloads

**Candidate Name:** Jay Patel
**GitHub Profile:** https://github.com/jaypatel29042000-glitch
**Program:** AWS Cloud & AI Internship Program
**Submission Date:** October 2026

---

### 1. Executive Summary
This capstone project implements an enterprise-grade AWS multi-tier network topology following the AWS Well-Architected Framework. It establishes two segregated VPCs: VPC 1 (28.0.0.0/16) for administrative and application compute, and VPC 2 (28.200.0.0/16) for isolated target workloads. Administrative jump access is enforced via an SSH Bastion host, while cross-VPC communication is enabled through AWS VPC Peering.

### 2. IP Addressing & CIDR Allocation Matrix
- EC2-1 (Bastion): VPC 1 | Subnet 1 (Public 28.0.1.0/24) | IGW attached
- EC2-2 (Internal App): VPC 1 | Subnet 2 (Private 28.0.2.0/24) | Routing to VPC 2 via Peering
- EC2-3 (Target Server): VPC 2 | Subnet 3 (Private 28.200.0.0/16) | Routing to VPC 1 via Peering

### 3. Firewall & Security Group Rules
- SG-1 (Bastion SG): Ingress TCP Port 22 from Admin Public IP; Egress all outbound.
- SG-2 (Private App SG): Ingress TCP Port 22 strictly from SG-1 ID; Egress all outbound.
- SG-3 (Target Isolated SG): Ingress TCP Port 22 and ICMP Echo Request strictly from 28.0.0.0/16; Egress all outbound.

### 4. Verification Evidence & Test Execution
- External Probe: Direct connections to private IPs timed out (Connection timed out), confirming zero public surface exposure.
- Bastion Jump Probe: SSH connection from Administrator -> Bastion -> Private App Server verified in 12ms.
- Peering Route Validation: 4 ICMP packets transmitted between VPC 1 Bastion and VPC 2 Target Server across the peering link: 4 packets transmitted, 4 received, 0% packet loss.
