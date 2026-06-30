## What this project builds

A production-style AWS security baseline deployed entirely with Terraform
Designed to represent the controls an organisation would want before deploying any workloads
Built as a root module calling individual child modules, one per security domain


## Why I built it

Career transition from technical support engineering into cloud security
Wanted to demonstrate hands-on ability rather than just certifications
Chose AWS because of existing AWS SAA certification and familiarity with the platform
Deliberately wrote every module from scratch rather than using registry modules — to own every decision


## Architecture

Diagram or description of module structure and how they connect
Why modules are separated by security domain rather than by resource type
How cross-module dependencies are handled (outputs, depends_on)
Why Terraform was chosen over CloudFormation


## Security controls and what they protect against
VPC

Why the default VPC is removed — its existence is a misconfiguration risk
Flow logs capturing ALL traffic — both accepted and rejected — for forensic investigation
Public and private subnet separation — compute never sits in a public subnet
Dedicated least-privilege IAM role for flow log delivery

KMS

Separate encryption keys per service — blast radius containment if a key is compromised
Key rotation enabled — reduces exposure window if a key is ever leaked
Why 20 day deletion window — recovery period for accidental deletion

IAM

Password policy values and why each was chosen
MFA enforcement logic — why BoolIfExists not Bool
Why NotAction was used rather than Action: * — preserves MFA setup actions
Why a group-based policy rather than attaching directly to users

CloudTrail

Multi-region trail — single region trails leave blind spots
enable_log_file_validation — SHA-256 hash chain proves logs haven't been tampered with
include_global_service_events — captures IAM, STS, Route53 which are critical for security
Why CloudTrail writes to both S3 and CloudWatch — S3 for long term retention, CloudWatch for real-time alerting
S3 bucket policy conditions — why aws:SourceArn condition locks delivery to this specific trail

GuardDuty

What GuardDuty detects that CloudTrail alone misses — behavioural anomalies, ML-based detection
Why S3 logs datasource is enabled — catches exfiltration patterns
Why malware protection on EBS is enabled
Why Kubernetes is disabled — not in scope, disabled deliberately not accidentally

Security Hub

Aggregates findings from GuardDuty, Config, and other services into one place
CIS AWS Foundations Benchmark v5.0.0 — what it covers and why CIS specifically
Why Security Hub depends_on GuardDuty

Alerting

Four alarms and what each one detects
Why root login should never happen in a well-run account
Why console login without MFA is a critical signal
Why security group and IAM policy changes need immediate visibility
Why evaluation_periods = 1 — security alarms should fire immediately, not after sustained breach


## Known limitations and future improvements

No explicit KMS key policy — currently relies on AWS default which grants root full access
No S3 access logging on the CloudTrail bucket — access to audit logs themselves isn't being audited
GuardDuty datasources block deprecated — should migrate to aws_guardduty_detector_feature resources
AWS Config module is empty — would add compliance rules for S3 public access, EBS encryption, root MFA, VPC flow logs. Estimated 2 to 3 hours additional work
No internet gateway or NAT gateway — intentional for this baseline, would be added per workload requirements
Password minimum length of 12 — CIS v1.4 recommends 14, worth increasing
No Terraform remote state — local state only, would use S3 backend with DynamoDB locking for a real team deployment
Single account — real enterprise would use AWS Organizations with SCPs enforced at OU level


## How to deploy

Prerequisites — AWS CLI configured, Terraform 1.6+, an AWS account
Clone the repo
Create terraform.tfvars with account ID and email — explain why this file is gitignored
terraform init
terraform plan
terraform apply
Confirm SNS email subscription when the email arrives
terraform destroy to tear down


## What I'd add next

AWS Config rules
Terraform remote state in S3 with DynamoDB locking
AWS Organizations and SCPs for multi-account enforcement
Automated remediation — Lambda triggered by GuardDuty findings
SIEM integration — ship CloudWatch logs to a centralised security platform