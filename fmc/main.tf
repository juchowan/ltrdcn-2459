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
  manage_deployment = var.manage_deployment
}

#provider "fmc" {
#    username  = "apiadmin"
#    password  = "C1sco12345"
#    url       = "https://198.18.130.200"
#}