terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
    }
  }
}

provider "fmc" {
}

module "fmc" {
  source  = "netascode/nac-fmc/fmc"
  version = "0.1.2"

  yaml_directories = ["data"]

  manage_deployment = var.manage_deployment

  write_default_values_file = "defaults.yaml"
}
