terraform {
  backend "s3" {
  }
}

variable "s3_backend_key" {
  type = string
}

variable "s3_backend_bucket" {
  type = string
}