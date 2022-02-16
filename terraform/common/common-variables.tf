variable "workspace" {
    type = string
}

variable "module" {
    type = string
}

locals {
  common_tags = {
    Workspace        = var.workspace
    Module = var.module
  }
}