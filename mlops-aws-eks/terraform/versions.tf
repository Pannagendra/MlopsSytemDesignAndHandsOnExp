terraform {
  required_version = ">= 1.9.7"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.72.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.5"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }    
  }
}