variable "cloudflare_zone_id" {
  type        = string
  description = "Domain zone"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
}

variable "cloudflare_email" {
  type        = string
  description = "Cloudflare account email"
}

variable "jit_name_prefix" {
  type        = string
  default     = "xm-cyber-poc"
  description = "Prefix for AWS resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "initial_setup" {
  type = string
}

variable "instance_types" {
  type    = list(string)
  default = ["c6a.large"]
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Jit tenant ID"
}
