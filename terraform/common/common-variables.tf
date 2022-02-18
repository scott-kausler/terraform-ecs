variable "module" {
    type = string
}

locals {
  default_tags = {
    Workspace        = terraform.workspace
    Module = var.module
  }
}

provider "aws" {
 default_tags {
   tags = local.default_tags
 }
}