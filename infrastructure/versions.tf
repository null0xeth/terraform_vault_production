
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.64.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.62.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.26.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.41.0"
    }
  }
}

