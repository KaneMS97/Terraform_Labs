## What this project builds

This project is designed to build a security baseline which has been entirely created with Terraform; the aim is to include controls that an organisation would want to include before deploying any workloads. It has been built with one root module that calls individual child modules, one per security domain.


## Why I built it

The reason I decided to do a project like this is because I'm looking to transition from being a technical support engineer into cloud computing, and this seemed like a good way to show hands-on ability and not just certifications. I decided to write every module from scratch rather than using the registry modules so that I know what each module contains, and I have experience building them while making my own decisions.


## Architecture

![Architecture Diagram](images\Securelanding.drawio.png)

I chose to use Terraform because of the ability to be used in hybrid environments, which are becoming more popular. So, even though I don't currently have experience in Azure or GCP, I can use Terraform, and using my knowledge in AWS and Terraform, I can use that to write infrastructure in other cloud environments.

I decided to use modules so that the code can be reusable and can be repeated while getting the same results. The reason I decided to separate them by security domain instead of resource type is because it makes it less confusing and easier to troubleshoot and upgrade. Instead of having to scroll through all the resources to find the one that correlates to a VPC, you can instead just go to the VPC module and find it in there.

Some of the modules depend on others, such as Security Hub on GuardDuty. CloudTrail needs the KMS, and Alerting needs the group name from the CloudTrail log; for this, I made use of the depends_on in Terraform. This way, everything that's needed as a prerequisite can be in place. I also made use of Outputs so that the other modules are able to pass specific values between themselves.

## Security controls and what they protect against

VPC

So, I first removed the default VPC, as it is a misconfiguration risk that could open up potential risks to the environment, as at default it allows all traffic to come through as long as it's a part of the same security group, and the default network ACL allows all traffic in and out. So, any resource that may be accidentally put into the default VPC is immediately exposed. I then created a public and a private subnet so that resources that don't need public access don't need to be put at risk and can stay in the private subnet.

I configured the flow logs so that I was able to see rejected and accepted traffic. This way, we could build a better picture if an attack was taking place. It's helpful being able to see what's rejected, such as brute force attempts or port scans, just as much as seeing what is accepted. I also created a least-privilege IAM role for the flow log delivery so that if there was a compromise, the actions that could be taken wouldn't be detrimental to the setup.

KMS

I decided to use different keys for each service, CloudTrail and S3. The reason is, in case one key becomes compromised, they won't be able to decrypt the data from CloudTrail and S3. This helps keep the blast radius contained. For how I've got the keys set up, I have enabled key rotation, which will reduce the amount of time the key is spent exposed if it's ever leaked. I have also added a 20-day deletion window so that the key can be recovered just in case of accidental deletion.

IAM

For the IAM, I created a password policy resource first to make sure all created passwords are secure. This came with a minimum password length, requiring the use of lowercase, uppercase, numbers, and symbols. I allowed users to be able to change their own password just in case they would like to change their password before the lifetime of the password expires. I also included password reuse prevention; I set this to 4 so that they can't reuse the same password again and again. I do see how with the enabling of allowing people to reset their own password how this could be abused, so users can set the same password again, and it would be something I would look into hardening.

For the AWS IAM policy document, I had to allow the users enough actions so they can manage their own account but not be able to have too many privileges. It was having to think of what a user would need on their first login, which is why for the condition test, I used BoolIfExists. If it doesn't exist yet, that means the user doesn't have 2FA set up yet, and they are then able to have access to more actions to help them get that set up. I also used not_actions; this is so new users are able to set up 2FA instead of everything being denied. If it does exist but is set to false, then the user is denied. I have used a group policy instead of attaching it to each user so that when a new user is added to the group, they are instantly under the policy. This helps keep it scalable and consistent.

CloudTrail

CloudTrail is normally used to monitor AWS activity. It records all activity made with information like who made the call, when, and from where. It also keeps things such as event history and allows for real-time monitoring.

The reason I have CloudTrail delivers to both CloudWatch and S3 is because they serve different purposes. CloudWatch can be used to provide more detailed insights and also gives you the ability to set up alarms if a condition is met. S3 is mainly used to store the data for long-term storage and for any forensic investigations if needed.

I enabled a multi-region trail so that all regions are being watched, not just one. If an attacker saw CloudTrail only being active in one region, they could pivot and attack from a different one. This way, it keeps everything monitored.

I decided to enable_log_file_validation with a SHA-256 hash. The main reason for doing this is to help prove that logs haven't been tampered with and so that they can be used in digital investigations and can be treated as reliable. In addition to this, I also encrypted the S3 bucket so if any attackers did gain access, they wouldn't be able to read the files without the KMS key.

I also decided to keep "include_global_service_events" at its default so that other events are also included in the trail, such as IAM and Route53. This is to make everything more secure and gives access to more information if an attack did occur.

I had it use the aws:SourceArn variable to make sure that it is using the correct trail, and so if an attack happened, someone couldn't create a new trail and be able to access the S3 bucket that way.

GuardDuty

The reason I have set up GuardDuty is because it picks up on things that CloudTrail alone could miss, things such as behavioural anomalies, and uses ML-based detection.

I have set up GuardDuty using datasources. This is deprecated, and I know I should use aws_guardduty_detector_feature, but for time and what I wanted to do, I have stayed with the datasources. This will be something I update and will come back to.

GuardDuty has been set up in a way so that it can monitor the s3_logs; this is so it can pick up on any patterns of exfiltration using ML. I have also enabled malware protection so it can scan EC2 and EBS volumes for malware. For Kubernetes, I have had this disabled because I haven't added any Kubernetes to this system, but it can be changed quickly and easily.

Security Hub

Security Hub is a useful service that helps aggregate findings from GuardDuty and other services into one place. I have set it up to use the CIS AWS Foundations Benchmark v5.0.0; the reason for this is because it is the latest benchmark available at the time of creating. It serves as a set of security configuration best practices for AWS that are industry-accepted; it ranges from operating systems to cloud services and network devices. I have set it up so that Security Hub depends_on GuardDuty. The reason for this is so that GuardDuty is created first, then Security Hub, so that it can be linked up to Security Hub as soon as it's created instead of having to be coded later or manually added once created.

Alerting

The first alarm is set up so that whenever the Root account is used, an email is sent. The reason for this is because your root account should never be used past setup; another account with admin rights should always be used before the root account. So, any use of the Root account needs to be investigated.

The second alarm is to make sure that any account that logs in without MFA is immediately alerted, and an investigation be started, and MFA is manually applied to the account. To help add a layer of protection to the account.

The third and fourth alarms are set up to monitor our security group and IAM policies to make sure no changes happen. In case someone gets into a low-level account, they won't be able to edit the security group or IAM policies, so they can't do privilege escalation without someone being made aware.

I set the evaluation periods on all of these alarms to 1. The reason for that is so that the alarms fire immediately and not after a sustained breach.

## Known limitations and future improvements

No explicit KMS key policy - currently relies on AWS default which grants root full access

No S3 access logging on the CloudTrail bucket - access to audit logs themselves isn't being audited

GuardDuty datasources block deprecated - should migrate to aws_guardduty_detector_feature resources

AWS Config module is empty - would add compliance rules for S3 public access, EBS encryption, root MFA, VPC flow logs. Estimated 2 to 3 hours additional work

No internet gateway or NAT gateway - intentional for this baseline, would be added per workload requirements

No Terraform remote state - local state only, would use S3 backend with DynamoDB locking for a real team deployment

Single account - real enterprise would use AWS Organizations with SCPs enforced at OU level


## How to deploy

Prerequisites - AWS CLI configured, Terraform 1.6+, an AWS account
Clone the repo
Create terraform.tfvars with account ID and email - this has been ignored so as not to appear in the repo so I don't leak my own account details while testing.
terraform init
terraform plan
terraform apply
Confirm SNS email subscription when the email arrives
terraform destroy to tear down

## What I'd add next

The below are things that I plan to add and will add as I continue my journey in learning Terraform and AWS.

AWS Config rules
Terraform remote state in S3 with DynamoDB locking
AWS Organizations and SCPs for multi-account enforcement
Automated remediation - Lambda triggered by GuardDuty findings
SIEM integration - ship CloudWatch logs to a centralised security platform