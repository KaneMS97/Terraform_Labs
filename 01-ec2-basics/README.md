## Objective
Deploy an EC2 instance on AWS using Terraform as a first introduction 
to infrastructure as code.

## Architecture Overview
Single EC2 instance deployed into the default VPC in eu-west-2 
using a t2.micro Amazon Linux 2 AMI.

## Key Decisions
- Used t2.micro to stay within the AWS free tier
- Deployed to eu-west-2 (London) as the closest region
- Tagged the instance for easy identification in the console

## Validation
Confirmed the instance appeared in the AWS EC2 console in eu-west-2 
with the correct instance type and Name tag. Successfully ran 
terraform destroy to tear down cleanly afterwards.

## Skills Demonstrated
- Terraform core workflow — init, plan, apply, destroy
- AWS provider configuration
- Declaring resources and tags in HCL
- Connecting Terraform to AWS via CLI credentials