terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
      version = "2.0.0-beta1"
    }
  }
}

module "fmc" {
  source            = "netascode/nac-fmc/fmc"
  version           = "0.0.1"
  
  yaml_directories = ["data"]

  manage_deployment = var.manage_deployment
}

#provider "fmc" {
#    username  = "apiadmin"
#    password  = "C1sco12345"
#    url       = "https://198.18.130.200"
#}