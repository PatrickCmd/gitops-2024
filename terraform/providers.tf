terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment  # Pass in 'Dev', 'Stage', or 'Prod'
      Service     = var.service_name # Pass in the name of the service (e.g., 'grafana')
    }
  }
}