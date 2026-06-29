module "vpc" {
  source = "./modules/vpc"

  name          = "my-vpc"
  cidr_block    = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

}
module "kms" {
  source = "./modules/kms"
}

module "iam" {
  source     = "./modules/iam"
  name       = ""
  account_id = ""
}

module "cloudtrail" {
  source      = "./modules/cloudtrail"
  account_id  = "your-account-id"
  kms_key_arn = module.kms.cloud_trail_kms_key_arn
}

module "guardduty" {
  source = "./modules/guardduty"
}

module "securityhub" {
  source     = "./modules/securityhub"
  depends_on = [module.guardduty]
}

module "alerting" {
  source = "./modules/alerting"
  email  = "example@hotmail.com"
}