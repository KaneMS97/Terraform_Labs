## Objective
To Take my Lab 2 VPC code and restructure it into three separate files.

## Architecture Overview
same VPC setup as Lab 2 but now split across three files

## Key Decisions
Used a map type for name tags rather than individual variables as it 
keeps related values grouped under one block and demonstrates 
different variable types beyond just string.

Variables were used throughout to make the code reusable. In a 
real team environment the same main.tf file could be shared across 
development and production as each environment just needs its own 
variables file with different values like instance sizes or CIDR 
blocks, without touching the core infrastructure code.

Outputs were added to surface useful resource information directly 
in the terminal after apply — VPC ID, EC2 public IP, subnet ID 
and security group ID which helps remove the need to hunt through the AWS 
console for values.

## Validation
outputs printed to terminal after apply showing VPC ID, EC2 public IP, subnet ID, security group ID without having to search through the CLI or the console.

## Skills Demonstrated
Terraform variable types - string and map
Separating code into variables.tf, main.tf, outputs.tf
Referencing variables with var.variable_name
Outputting resource attributes after apply and confirming the output
Making infrastructure reusable and configurable