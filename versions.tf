terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
    #    http = {
    #      source  = "hashicorp/http"
    #      version = "~> 1.2.0"
    #    }    
  }
  required_version = ">= 0.14"
}