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
| <a name="module_aws_bootstrap"></a> [aws\_bootstrap](#module\_aws\_bootstrap) | ../../../modules/aws_bootstrap | n/a |
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
| <a name="input_acme"></a> [acme](#input\_acme) | n/a | `any` | n/a | yes |
| <a name="input_aws_iam_context"></a> [aws\_iam\_context](#input\_aws\_iam\_context) | n/a | `any` | n/a | yes |
| <a name="input_aws_kms_context"></a> [aws\_kms\_context](#input\_aws\_kms\_context) | n/a | `any` | n/a | yes |
| <a name="input_cloud-init"></a> [cloud-init](#input\_cloud-init) | n/a | <pre>object({<br>    general = optional(object({<br>      filename = optional(string, "cloud-init.yaml")<br>      timezone = optional(string, "Europe/Amsterdam")<br>    }))<br>    network = optional(object({<br>      include  = optional(bool)<br>      networks = optional(number)<br>      dhcp4    = optional(bool)<br>    }))<br><br>    files = optional(list(object({<br>      path        = optional(string)<br>      permissions = optional(string)<br>      content     = optional(any)<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_cluster_spec"></a> [cluster\_spec](#input\_cluster\_spec) | n/a | <pre>map(object({<br>    component_id   = optional(string)<br>    component_size = optional(number, 3)<br>    base_id        = optional(number, 300)<br>    base_name      = optional(string, "machine")<br><br>    config = object({<br>      cpu_cores = optional(number, 4)<br>      memory    = optional(number, 4096)<br><br>      disks = optional(map(object({<br>        datastore_id = optional(string)<br>        file_id      = optional(string)<br>        interface    = optional(string)<br>        size         = optional(number)<br>        ssd          = optional(bool)<br>      })))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_provider_aws"></a> [provider\_aws](#input\_provider\_aws) | n/a | <pre>object({<br>    region = optional(string, "eu-west-1")<br>  })</pre> | `{}` | no |
| <a name="input_provider_proxmox"></a> [provider\_proxmox](#input\_provider\_proxmox) | n/a | <pre>object({<br>    endpoint          = optional(string, "https://pve.dirtyhonk.life:8006")<br>    username          = optional(string, "root")<br>    agent_socket      = optional(string, "/run/current-system/sw/bin/ssh-agent")<br>    node              = optional(string, "pve")<br>    default_datastore = optional(string, "local")<br>  })</pre> | `{}` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | n/a | `list(string)` | <pre>[<br>  "terraform",<br>  "infrastructure"<br>]</pre> | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | n/a | <pre>object({<br>    name       = optional(string, "terraform-state")<br>    acl        = optional(string, "private")<br>    versioning = optional(string, "Enabled")<br>    lock       = optional(bool, true)<br>    key        = optional(string, "terraform/stacks/by-id/honkfrastructure/terraform.tfstate")<br>    table      = optional(string, "terraform-lock")<br>  })</pre> | `{}` | no |
| <a name="input_templates"></a> [templates](#input\_templates) | n/a | `map(any)` | `{}` | no |
| <a name="input_vm_password"></a> [vm\_password](#input\_vm\_password) | n/a | `string` | n/a | yes |
| <a name="input_vm_ssh_keys"></a> [vm\_ssh\_keys](#input\_vm\_ssh\_keys) | n/a | `list(string)` | <pre>[<br>  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmJacbLyO/WVFf6GrMVx2l31xGxynWrAEkzX3+myQzW null0x@ansible"<br>]</pre> | no |
| <a name="input_vm_username"></a> [vm\_username](#input\_vm\_username) | n/a | `string` | `"null0x"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->