variable "acme" {}
variable "aws_iam_context" {}
variable "aws_kms_context" {}

variable "provider_proxmox" {
  type = object({
    endpoint          = optional(string, "https://pve.dirtyhonk.life:8006")
    username          = optional(string, "root")
    agent_socket      = optional(string, "/run/current-system/sw/bin/ssh-agent")
    node              = optional(string, "pve")
    default_datastore = optional(string, "local")
  })
  default = {}
}

variable "provider_aws" {
  type = object({
    region = optional(string, "eu-west-1")
  })
  default = {}
}

variable "vm_username" {
  type    = string
  default = "null0x"
}

variable "vm_password" {
  type      = string
  sensitive = true
}

variable "vm_ssh_keys" {
  type    = list(string)
  default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmJacbLyO/WVFf6GrMVx2l31xGxynWrAEkzX3+myQzW null0x@ansible"]
}

variable "resource_tags" {
  type    = list(string)
  default = ["terraform", "infrastructure"]
}

variable "s3_bucket" {
  type = object({
    name       = optional(string, "terraform-state")
    acl        = optional(string, "private")
    versioning = optional(string, "Enabled")
    lock       = optional(bool, true)
    key        = optional(string, "terraform/stacks/by-id/honkfrastructure/terraform.tfstate")
    table      = optional(string, "terraform-lock")
  })
  default = {}
}

variable "cloud-init" {
  type = object({
    general = optional(object({
      filename = optional(string, "cloud-init.yaml")
      timezone = optional(string, "Europe/Amsterdam")
    }))
    network = optional(object({
      include  = optional(bool)
      networks = optional(number)
      dhcp4    = optional(bool)
    }))

    files = optional(list(object({
      path        = optional(string)
      permissions = optional(string)
      content     = optional(any)
    })))
  })
}

variable "cluster_spec" {
  type = map(object({
    component_id   = optional(string)
    component_size = optional(number, 3)
    base_id        = optional(number, 300)
    base_name      = optional(string, "machine")

    config = object({
      cpu_cores = optional(number, 4)
      memory    = optional(number, 4096)

      disks = optional(map(object({
        datastore_id = optional(string)
        file_id      = optional(string)
        interface    = optional(string)
        size         = optional(number)
        ssd          = optional(bool)
      })))
    })
  }))
}

### MODULE: BASE/TEMPLATE_FILE ###########################################
variable "templates" {
  type    = map(any)
  default = {}
}


