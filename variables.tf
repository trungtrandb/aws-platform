variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "admin_cidr" {
  description = "CIDR SSH/Kubernetes API from outside"
  type        = string
  default     = "0.0.0.0/0"
}

variable "k3s_token" {
  type        = string
  sensitive   = true
  description = "K3s token"
  default     = "replace-with-a-strong-random-token"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key"
}