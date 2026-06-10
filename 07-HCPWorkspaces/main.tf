terraform {
    
  cloud {
    organization = "Kanes-Terraform"

    workspaces {
      name = "kanes-test-ws"
    }
  }
}