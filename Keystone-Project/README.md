## What this project builds

This Project is designed to build a security baseline which has been entirely created with terraform, the aim is to include controls that and organisation would want to include before deploying any workloads. It has been built with one root module that calls individual child modules, one per security domain.


## Why I built it

The reason i decided to do a project like this is because im looking to transition from being a technical support engineer into cloud computing and this seemed like a good way to show hands-on ability and not just certifications. I decided to write every module from scratch rather than using the registry modules so that i know what each module contains and i have experience building them while making my own decisions.


## Architecture

Diagram or description of module structure and how they connect
Why modules are separated by security domain rather than by resource type
How cross-module dependencies are handled (outputs, depends_on)


I chose to use Terraform because of the ability to be used in hybrid enviroments which are becoming more popular so even though i dont currently have experience in Azure or GCP I can use Terraform and hopefully using my knowledge in AWS and terraform i can use that to write infrastrcture in other cloud enviroments.

## Security controls and what they protect against
VPC

So I first removed the default VPC as it is a misconfiguration risk that could open up potential risks to the enviroment as at default it allows all traffic to come through as long as its apart fo the same security group and the default network ACL allows all traffic in and out so any resource that maybe accidentally put into the default VPC is imediately exposed.I then created a public and a private subnet so that resources that dont need public access dont need to be put at risk and can stay in the private subnet.

I configured the flow logs so that i was abel to see rejected and accepted traffic this way we could build a better picture if an attack was taking place its helpful being able to see whats rejected such as brute force attempts or port scans just as much as seeing what is accepted. I also created a least privilege IAM role for the flow log delivery so that if there was a compromise the actions that could be taken wouldnt be detrimental to the setup. 


KMS

Separate encryption keys per service — blast radius containment if a key is compromised
Key rotation enabled — reduces exposure window if a key is ever leaked
Why 20 day deletion window — recovery period for accidental deletion

IAM

Password policy values and why each was chosen
MFA enforcement logic — why BoolIfExists not Bool
Why NotAction was used rather than Action: * — preserves MFA setup actions
Why a group-based policy rather than attaching directly to users

For the IAM I created a password policy resource 

CloudTrail

CloudTrail is normally used to monitor AWS activity, it records all activity made with information like who made the call, when and from where. It also keeps things such as event history and allows for real time monitoring.

The reason we have CLoudtrail backup to both Cloudwatch and S3 is because Cloudwatch can be used to provide more detailed insights and also gives you the ability to set up alarms if a condition is met. S3 is mainly used to store the data for long term storage and for any forensic investigations if needed.

I enabled multi-region trail so that all regions are being watched not just one if an attacker saw cloudtrail only being active in one region they could pivot and attack from a different one this way it keeps everything monitored.

I decided to enable_log_file_validation with a SHA-256 hash the main reason for doing this is to help prove that logs havent been tampered with and so that they can be used in digital investigations and can be treated as reliable.In Addition to this i also encrypted the s3 bucket so if any attackers did gain access they wouldnt be able to read the files without the KMS key.

I also decided to keep "include_global_service_events" at its default so that other events are also included in the trail such as IAM and Route53 this is to make everything more secure and gives access to more information if an attack did occuer.

I had it used the aws:SourceArn variable to make sure that it is using the correct trail and so if an attack happened someone couldnt create a new trail and be able to access the s3 bucket that way.

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

The first alarm is setup so that whenever the Root account is used an email is sent the reason for this is because your root account should never be used past set up another account with admin rights should always be used before the root account. So any use of the Root account needs to be investigated.

The second alarm is to make sure that any account that logs in without mfa is immediately remediated and mfa is applied to the account. To help add a layer of protection to the account.

The third and forth alarms are set up to monitor our security group and IAM policys to make sure no changes happen incase someone gets in to a low level account they wont be able to edit the security group or iam policys so they cant do privilage escalation without someone being made aware.

I set the evaluation periods on all of these alarms to 1 the reason for that is so that the alarms fire immediately and not after a sustained breach.

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