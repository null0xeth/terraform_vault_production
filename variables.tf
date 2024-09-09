variable "acme" {
  type        = any
  description = "Empty variable holding the ACME configuration, passed to the letsencrypt module."
}

variable "aws_kms_context" {
  description = "Configuration of the AWS KMS key to be passed to the aws-bootstrap module."
  type = object({
    aws_kms_key_create = optional(bool)
    aws_kms_key_config = optional(object({
      description = optional(string)
      rotation    = optional(bool)
      deletion    = optional(number)
    }))
    aws_kms_key_policy = optional(object({
      Id = optional(string)
      Statement = optional(list(object({
        Action    = optional(string)
        Effect    = optional(string)
        Principal = optional(map(any))
        Resource  = optional(string)
        Sid       = optional(string)
      })))
      Version = optional(string)
    }))
  })
}

variable "aws_iam_context" {
  description = "Configuration of the IAM user to be passed to the aws-bootstrap module."
  type = object({
    aws_iam_user             = optional(string)
    aws_iam_user_path        = optional(string)
    aws_iam_user_tags        = optional(map(any))
    aws_iam_user_policy_name = optional(string)

    aws_iam_user_policy = optional(object({
      Version = optional(string, "2012-10-17")
      Statement = list(object({
        Effect   = optional(string)
        Action   = optional(list(string))
        Resource = optional(string)
      }))
    }))
  })
  default = null
}

variable "provider_proxmox" {
  description = "bpg/proxmox provider configuration variables"
  type = object({
    endpoint          = optional(string, "https://path.to.pve:8006")
    username          = optional(string, "root")
    agent_socket      = optional(string, "/run/current-system/sw/bin/ssh-agent")
    node              = optional(string, "pve")
    default_datastore = optional(string, "local")
  })
  default = {}
}

variable "provider_aws" {
  description = "hashicorp/aws provider configuration variables"
  type = object({
    region = optional(string, "eu-west-1")
  })
  default = {}
}

variable "vm_username" {
  description = "Name of the user that will access the created VMs"
  type        = string
  default     = "null0x"
}

variable "vm_password" {
  description = "Note: export as env variable `TF_VAR_vm_password`. Password of the user that will access the created VMs."
  type        = string
  sensitive   = true
}

variable "vm_ssh_keys" {
  description = "List of public ssh keys to be added to the VMs"
  type        = list(string)
  default     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmJacbLyO/WVFf6GrMVx2l31xGxynWrAEkzX3+myQzW null0x@ansible"]
}

variable "resource_tags" {
  description = "List of resource tags to be added to all created resources"
  type        = list(string)
  default     = ["terraform", "infrastructure"]
}

variable "s3_bucket" {
  description = "Configuration of the S3 bucket where we will store remote state."
  type = object({
    name       = optional(string, "terraform-state")
    acl        = optional(string, "private")
    versioning = optional(string, "Enabled")
    lock       = optional(bool, true)
    key        = optional(string, "terraform/stacks/by-id/bucket/terraform.tfstate")
    table      = optional(string, "terraform-lock")
  })
  default = {}
}

variable "cloud-init" {
  description = "Configuration variables passed to the cloud-init module"
  type = object({
    general = optional(object({
      filename = optional(string, "cloud-init.yaml")
      timezone = optional(string, "Your/Tz")
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
  # cluster_spec = { node_group = {} }
  description = "Contains the cluster topology and configuration variables passed to the cluster module."
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
  description = "Map of Templates that we will be rendering in the template_renderer module"
  type        = map(any)
  default     = {}
}


