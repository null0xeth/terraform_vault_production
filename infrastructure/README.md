<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_acme"></a> [acme](#requirement\_acme) | 2.26.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.64.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.41.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.2 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >=0.62.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_bootstrap"></a> [aws\_bootstrap](#module\_aws\_bootstrap) | github.com/null0xeth/aws_bootstrap | n/a |
| <a name="module_cloud-init"></a> [cloud-init](#module\_cloud-init) | ../../../base/cloud-init | n/a |
| <a name="module_deployment"></a> [deployment](#module\_deployment) | ../../../modules/vm_cluster | n/a |
| <a name="module_letsencrypt_ssl"></a> [letsencrypt\_ssl](#module\_letsencrypt\_ssl) | ../../../modules/letsencrypt_ssl_cert | n/a |
| <a name="module_render_ansible_templates"></a> [render\_ansible\_templates](#module\_render\_ansible\_templates) | ../../../base/template_file | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.provisioning](https://registry.terraform.io/providers/hashicorp/null/3.2.2/docs/resources/resource) | resource |
| [null_resource.provisioning_qol](https://registry.terraform.io/providers/hashicorp/null/3.2.2/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme"></a> [acme](#input\_acme) | Empty variable holding the ACME configuration, passed to the letsencrypt module. | `any` | n/a | yes |
| <a name="input_aws_iam_context"></a> [aws\_iam\_context](#input\_aws\_iam\_context) | Configuration of the IAM user to be passed to the aws-bootstrap module. | <pre>object({<br>    aws_iam_user             = optional(string)<br>    aws_iam_user_path        = optional(string)<br>    aws_iam_user_tags        = optional(map(any))<br>    aws_iam_user_policy_name = optional(string)<br><br>    aws_iam_user_policy = optional(object({<br>      Version = optional(string, "2012-10-17")<br>      Statement = list(object({<br>        Effect   = optional(string)<br>        Action   = optional(list(string))<br>        Resource = optional(string)<br>      }))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_aws_kms_context"></a> [aws\_kms\_context](#input\_aws\_kms\_context) | Configuration of the AWS KMS key to be passed to the aws-bootstrap module. | <pre>object({<br>    aws_kms_key_create = optional(bool)<br>    aws_kms_key_config = optional(object({<br>      description = optional(string)<br>      rotation    = optional(bool)<br>      deletion    = optional(number)<br>    }))<br>    aws_kms_key_policy = optional(object({<br>      Id = optional(string)<br>      Statement = optional(list(object({<br>        Action    = optional(string)<br>        Effect    = optional(string)<br>        Principal = optional(map(any))<br>        Resource  = optional(string)<br>        Sid       = optional(string)<br>      })))<br>      Version = optional(string)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_cloud-init"></a> [cloud-init](#input\_cloud-init) | Configuration variables passed to the cloud-init module | <pre>object({<br>    general = optional(object({<br>      filename = optional(string, "cloud-init.yaml")<br>      timezone = optional(string, "Your/Tz")<br>    }))<br>    network = optional(object({<br>      include  = optional(bool)<br>      networks = optional(number)<br>      dhcp4    = optional(bool)<br>    }))<br><br>    files = optional(list(object({<br>      path        = optional(string)<br>      permissions = optional(string)<br>      content     = optional(any)<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_cluster_spec"></a> [cluster\_spec](#input\_cluster\_spec) | Contains the cluster topology and configuration variables passed to the cluster module. | <pre>map(object({<br>    component_id   = optional(string)<br>    component_size = optional(number, 3)<br>    base_id        = optional(number, 300)<br>    base_name      = optional(string, "machine")<br><br>    config = object({<br>      cpu_cores = optional(number, 4)<br>      memory    = optional(number, 4096)<br><br>      disks = optional(map(object({<br>        datastore_id = optional(string)<br>        file_id      = optional(string)<br>        interface    = optional(string)<br>        size         = optional(number)<br>        ssd          = optional(bool)<br>      })))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_provider_aws"></a> [provider\_aws](#input\_provider\_aws) | hashicorp/aws provider configuration variables | <pre>object({<br>    region = optional(string, "eu-west-1")<br>  })</pre> | `{}` | no |
| <a name="input_provider_proxmox"></a> [provider\_proxmox](#input\_provider\_proxmox) | bpg/proxmox provider configuration variables | <pre>object({<br>    endpoint          = optional(string, "https://path.to.pve:8006")<br>    username          = optional(string, "root")<br>    agent_socket      = optional(string, "/run/current-system/sw/bin/ssh-agent")<br>    node              = optional(string, "pve")<br>    default_datastore = optional(string, "local")<br>  })</pre> | `{}` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | List of resource tags to be added to all created resources | `list(string)` | <pre>[<br>  "terraform",<br>  "infrastructure"<br>]</pre> | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Configuration of the S3 bucket where we will store remote state. | <pre>object({<br>    name       = optional(string, "terraform-state")<br>    acl        = optional(string, "private")<br>    versioning = optional(string, "Enabled")<br>    lock       = optional(bool, true)<br>    key        = optional(string, "terraform/stacks/by-id/bucket/terraform.tfstate")<br>    table      = optional(string, "terraform-lock")<br>  })</pre> | `{}` | no |
| <a name="input_templates"></a> [templates](#input\_templates) | Map of Templates that we will be rendering in the template\_renderer module | `map(any)` | `{}` | no |
| <a name="input_vm_password"></a> [vm\_password](#input\_vm\_password) | Note: export as env variable `TF_VAR_vm_password`. Password of the user that will access the created VMs. | `string` | n/a | yes |
| <a name="input_vm_ssh_keys"></a> [vm\_ssh\_keys](#input\_vm\_ssh\_keys) | List of public ssh keys to be added to the VMs | `list(string)` | <pre>[<br>  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmJacbLyO/WVFf6GrMVx2l31xGxynWrAEkzX3+myQzW null0x@ansible"<br>]</pre> | no |
| <a name="input_vm_username"></a> [vm\_username](#input\_vm\_username) | Name of the user that will access the created VMs | `string` | `"null0x"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->