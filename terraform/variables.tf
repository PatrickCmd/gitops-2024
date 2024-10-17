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
