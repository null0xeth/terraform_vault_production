terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "honkus-infrastructuris"
    key            = "terraform/stacks/by-id/honkfrastructure/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "proxmox" {
  endpoint = var.provider_proxmox.endpoint
  insecure = true
  ssh {
    agent        = true
    username     = var.provider_proxmox.username
    agent_socket = var.provider_proxmox.agent_socket
  }
}

provider "aws" {
  region                   = var.provider_aws.region
  shared_config_files      = ["/home/null0x/.aws/config"]
  shared_credentials_files = ["/home/null0x/.aws/credentials"]
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}



