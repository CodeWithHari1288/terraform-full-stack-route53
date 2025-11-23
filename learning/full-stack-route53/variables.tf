variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "azs" {
  description = "AZs to use"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "domain_name" {
  description = "Root domain name (already registered)"
  type        = string
  default     = "test2311.com"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into EC2"
  type        = string
  default     = "0.0.0.0/0"
}
