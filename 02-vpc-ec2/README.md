## Objective
Deploy a complete and functional VPC environment on AWS using 
Terraform, including networking, security, and compute resources 
— all without touching the AWS console.

## Architecture Overview
Custom VPC with a /16 CIDR block containing a public subnet, 
internet gateway for outbound access, route table directing 
traffic to the internet, security group controlling inbound 
and outbound traffic, and an EC2 instance deployed into 
the subnet.

## Key Decisions
- 10.0.0.0/16 chosen for the VPC to provide enough IP space 
  for future subnets
- 10.0.1.0/24 for the public subnet giving 251 usable addresses
- Security group restricted to port 80 (HTTP) and port 22 (SSH) 
  inbound only - no unnecessary exposure
- t2.micro used to stay within AWS free tier
- Route table explicitly routes 0.0.0.0/0 to the internet 
  gateway to enable public internet access

## Validation
Verified all resources appeared correctly in the AWS console — 
VPC, subnet, internet gateway, route table associations, 
security group rules and EC2 instance running in the 
correct subnet.

## Skills Demonstrated
- Building a custom VPC from scratch in Terraform
- Understanding of AWS networking - subnets, route tables, 
  internet gateways and how they connect
- Security group configuration - least privilege inbound rules
- Resource referencing in Terraform using resource_type.name.id
- Terraform dependency management - resources built in the 
  correct order automatically
- Route table association linking subnets to routing rules 