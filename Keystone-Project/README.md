## What this project builds

This Project is designed to build a security baseline which has been entirely created with terraform, the aim is to include controls that and organisation would want to include before deploying any workloads. It has been built with one root module that calls individual child modules, one per security domain.


## Why I built it

The reason i decided to do a project like this is because im looking to transition from being a technical support engineer into cloud computing and this seemed like a good way to show hands-on ability and not just certifications. I decided to write every module from scratch rather than using the registry modules so that i know what each module contains and i have experience building them while making my own decisions.


## Architecture

![Architecture Diagram](images\Securelanding.drawio.png)

I chose to use Terraform because of the ability to be used in hybrid enviroments which are becoming more popular so even though i dont currently have experience in Azure or GCP I can use Terraform and using my knowledge in AWS and terraform i can use that to write infrastrcture in other cloud enviroments.

I decided to use modules so that the code can be reuseable and can be repeated while getting the same results. The reason i decided to seperate them by security domain instead of resource type is because it makes it less confusing and easier to troubleshoot and upgrade insteaad of having to scroll through all the resources to find the one that corrolates to VPC you can instead just go to the VPC module and find it in there.

some of the modules depend on others such as Security Hub on GuardDuty, CloudTrail needs the KMS and Alerting needs the group name from the CloudTrail log, for this i made use of the depends_on in terraform this way everything thats needed as a pre-requisite can be in place.Also made use of Outputs so that the other modules are able to pass specific values between themselves.

## Security controls and what they protect against
VPC

So I first removed the default VPC as it is a misconfiguration risk that could open up potential risks to the enviroment as at default it allows all traffic to come through as long as its apart fo the same security group and the default network ACL allows all traffic in and out so any resource that maybe accidentally put into the default VPC is imediately exposed.I then created a public and a private subnet so that resources that dont need public access dont need to be put at risk and can stay in the private subnet.

I configured the flow logs so that i was abel to see rejected and accepted traffic this way we could build a better picture if an attack was taking place its helpful being able to see whats rejected such as brute force attempts or port scans just as much as seeing what is accepted. I also created a least privilege IAM role for the flow log delivery so that if there was a compromise the actions that could be taken wouldnt be detrimental to the setup. 


KMS

I decided to use different keys for each service cloud trail and s3 the reason is incase one key becomes compromised they wont be able to decrypt the data from cloudtrial and s3. This helps keep the blast radius contained. For how ive got the keys setup I have enabled key rotation which will reduce the amount of time the key is spent exposed if its ever leaked, i have also added a 20 day deletion window so that the key can be recovered just incase of accidental deletion.

IAM

For the IAM I created a password policy resource first to make sure all created passwords are secure this came with minimum password length,require the use of lowercase,uppercase,numbers and symbols. I allowed users to be able to change their own password just incase they would like to chnage their password before the lifetime of the password expires. I also included password reuse prevention i set this to 4 just so that they cant reuse the same password again and again. I do see how with the enabling of allowing people to reset their own password how this could be abused so users can set the same password again and would be something i would look into hardening. 

For the aws iam policy document i had to allow the users enough actions so they can mange their own account but not be able to have too many privlages it was having to think of what would a user need on their first login, which is why for the condition test i used BoolIfExists if it doesnt exist yet that means the user doesnt have 2fa set up yet and they are then able to have access to more actions to help them get that set up I also used not_actions this is so new users are able to set up 2fa instead of everything being denied. If it does exist but is set to false then the user is denied. I have used a group policy instead of attaching it to each user so that when a new user is added to the group they are instantly under the policy this helps keep it scalable and consistent.

CloudTrail

CloudTrail is normally used to monitor AWS activity, it records all activity made with information like who made the call, when and from where. It also keeps things such as event history and allows for real time monitoring.

The reason we have CLoudtrail backup to both Cloudwatch and S3 is because Cloudwatch can be used to provide more detailed insights and also gives you the ability to set up alarms if a condition is met. S3 is mainly used to store the data for long term storage and for any forensic investigations if needed.

I enabled multi-region trail so that all regions are being watched not just one if an attacker saw cloudtrail only being active in one region they could pivot and attack from a different one this way it keeps everything monitored.

I decided to enable_log_file_validation with a SHA-256 hash the main reason for doing this is to help prove that logs havent been tampered with and so that they can be used in digital investigations and can be treated as reliable.In Addition to this i also encrypted the s3 bucket so if any attackers did gain access they wouldnt be able to read the files without the KMS key.

I also decided to keep "include_global_service_events" at its default so that other events are also included in the trail such as IAM and Route53 this is to make everything more secure and gives access to more information if an attack did occuer.

I had it used the aws:SourceArn variable to make sure that it is using the correct trail and so if an attack happened someone couldnt create a new trail and be able to access the s3 bucket that way.

GuardDuty

The reason i have set up GuardDuty is because it picks up on things that CLoudTrail alone could miss things such as behavioural anomalies and uses ML-based detection.

i have set up guardduty using datasources this is depreceated and i know i should use aws_guardduty_detector_feature but for time and what i wanted to do i have staye dwith the datasources this will be something i update and will come back to.

GuardDuty has been set up in a way so that it can monitor the s3_logs this is so it can pick up on any patterns of exfiltration using ML, I have also enabled the malware protection so it can scan ec2 and ebs volumes for malware. For kubernetes i have had this disabled because i havent added any kubernetes to this system but it can be changed quickly and easily.

Security Hub

Security Hub is a usefull service that helps aggregates findings from GuardDuty and other services into one place, i ave set it up to use the CIS AWS foundations benchmark v5.0.0 the reason for this is because it is the latest benchmark available at the time of creating. It helps serves as a set of security configuration best practices for AWS that are industry accepted it ranges from operating systems to cloud services and network devices. I have set it up so that Security Hib depends_on GuardDuty the reason for this is so that GuardDuty is created first then Security Hub so that it can be linked up to Security Hub as soon as its created instead of having to be coded later or manually added once created.


Alerting

The first alarm is setup so that whenever the Root account is used an email is sent the reason for this is because your root account should never be used past set up another account with admin rights should always be used before the root account. So any use of the Root account needs to be investigated.

The second alarm is to make sure that any account that logs in without mfa is immediately alerted and an investigation be started and mfa is manually applied to the account. To help add a layer of protection to the account.

The third and forth alarms are set up to monitor our security group and IAM policys to make sure no changes happen incase someone gets in to a low level account they wont be able to edit the security group or iam policys so they cant do privilage escalation without someone being made aware.

I set the evaluation periods on all of these alarms to 1 the reason for that is so that the alarms fire immediately and not after a sustained breach.

## Known limitations and future improvements

No explicit KMS key policy — currently relies on AWS default which grants root full access

No S3 access logging on the CloudTrail bucket — access to audit logs themselves isn't being audited

GuardDuty datasources block deprecated — should migrate to aws_guardduty_detector_feature resources

AWS Config module is empty — would add compliance rules for S3 public access, EBS encryption, root MFA, VPC flow logs. Estimated 2 to 3 hours additional work

No internet gateway or NAT gateway — intentional for this baseline, would be added per workload requirements

No Terraform remote state — local state only, would use S3 backend with DynamoDB locking for a real team deployment

Single account — real enterprise would use AWS Organizations with SCPs enforced at OU level


## How to deploy

Prerequisites — AWS CLI configured, Terraform 1.6+, an AWS account
Clone the repo
Create terraform.tfvars with account ID and email - this has been ignored so as not to appear in the repo so i dont leak my own account details while testing.
terraform init
terraform plan
terraform apply
Confirm SNS email subscription when the email arrives
terraform destroy to tear down

## What I'd add next

THe below are things that i plan to add and will add as i continue my journey in learning terraform and AWS.

AWS Config rules
Terraform remote state in S3 with DynamoDB locking
AWS Organizations and SCPs for multi-account enforcement
Automated remediation - Lambda triggered by GuardDuty findings
SIEM integration - ship CloudWatch logs to a centralised security platform