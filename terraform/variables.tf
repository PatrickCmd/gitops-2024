variable "region" {
  type        = string
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type (e.g., t2.micro, m5.large) to use for the deployment"
  default     = "t3.micro"
}

variable "service_name" {
  type        = string
  description = "The name of the service for tagging purposes"
  default     = "grafana"
}

variable "environment" {
  type        = string
  description = "The environment where the infrastructure is deployed (Dev, Stage, Prod)"
  default     = "Prod"
}

