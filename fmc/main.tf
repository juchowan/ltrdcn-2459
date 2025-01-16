terraform {
  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "0.0.1"
    }
  }
}

module "fmc" {
  source            = "git::https://github.com/mmaciejc/terraform-fmc-nac-fmc"
  manage_deployment = true
}