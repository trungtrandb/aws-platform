variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "c7i-flex.large"
}

variable "admin_cidr" {
  description = "CIDR SSH/Kubernetes API from outside"
  type        = string
  default     = "0.0.0.0/0"
}

variable "k3s_token" {
  type        = string
  sensitive   = true
}