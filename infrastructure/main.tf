######### LOCAL VARIABLES ###################################################################################
locals {
  auth_bundle = {
    username = var.vm_username
    password = var.vm_password
    ssh_keys = var.vm_ssh_keys
  }
  flatmap = zipmap(module.deployment.server_name, module.deployment.server_ipv4)
  merged_map = {
    for tpl_id, tpl_conf in var.templates : tpl_id => {
      base_file = tpl_conf.base_file
      source    = file("${tpl_conf.template_source}")
      variables = merge(tpl_conf.variables, {
        ansible_map  = module.deployment.raw_map
        aws_user_map = module.aws_bootstrap.user
        region       = var.provider_aws.region
        aws_kms_map  = module.aws_bootstrap.kms
        dirty_map    = local.flatmap
      })
      destination  = tpl_conf.local_destination
      with_node_id = tpl_conf.with_node_id
    }
  }
}

######### MODULE: MODULES/LETSENCRYPT_SSL ###################################################################
module "letsencrypt_ssl" {
  source = "github.com/null0xeth/terraform_letsencrypt_certificate"
  acme   = var.acme
}

######### MODULE: MODULES/AWS_BOOTSTRAP #####################################################################
module "aws_bootstrap" {
  source          = "github.com/null0xeth/terraform_aws_bootstrap"
  provider_aws    = var.provider_aws
  aws_iam_context = var.aws_iam_context
  aws_kms_context = var.aws_kms_context
}

######### MODULE: BASE/CLOUD-INIT ###########################################################################
module "cloud-init" {
  source     = "github.com/null0xeth/terraform_pve_cloud_init"
  cloud-init = var.cloud-init
}

######### MODULE: MODULES/VM_CLUSTER ########################################################################
module "deployment" {
  source           = "github.com/null0xeth/terraform_pve_vm_cluster"
  auth_bundle      = local.auth_bundle
  cloud_init_id    = module.cloud-init.id
  cluster_spec     = var.cluster_spec
  provider_proxmox = var.provider_proxmox
  provider_aws     = var.provider_aws
  resource_tags    = var.resource_tags

  providers = {
    aws     = aws
    proxmox = proxmox
  }
}

#########  MODULE: BASE/TEMPLATE_FILE #######################################################################
module "render_ansible_templates" {
  for_each  = module.deployment.raw_map.vault_server
  source    = "github.com/null0xeth/terraform_template_renderer"
  templates = local.merged_map
  node_id   = each.key
}

#########  RESOURCES: PROVISIONING ##########################################################################
resource "null_resource" "provisioning" {
  for_each = module.deployment.raw_map.vault_server

  triggers = {
    always_run = "${timestamp()}"
  }
  connection {
    host        = each.value
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/ansible_ed25519")
  }

  ### CERTIFICATES ###
  provisioner "file" {
    source      = "../assets/generated/opt/vault/tls/fullchain.pem"
    destination = "/opt/vault/tls/${each.key}_fc.pem"
  }
  provisioner "file" {
    source      = "../assets/generated/opt/vault/tls/privkey.pem"
    destination = "/opt/vault/tls/${each.key}_pk.pem"
  }

  ### ENVIRONMENT VARIABLES ###
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R vault:vault /opt/vault",
      "sudo mkdir -p /etc/systemd/system/vault.service.d",
    ]
  }
  provisioner "file" {
    source      = "../assets/generated/home/${each.key}.env.sh"
    destination = "/home/null0x/env.sh"
  }

  provisioner "file" {
    source      = "../assets/generated/systemd/vault.service.d/${each.key}.env.conf"
    destination = "/etc/systemd/system/vault.service.d/env.conf"
  }

  ### VAULT CONFIG FILE ###
  provisioner "file" {
    source      = "../assets/generated/etc/vault.d/${each.key}.vault.hcl"
    destination = "/etc/vault.d/vault.hcl"
  }

}

resource "null_resource" "provisioning_qol" {
  for_each = module.deployment.raw_map.vault_server

  triggers = {
    always_run = "${timestamp()}"
  }
  connection {
    host        = each.value
    type        = "ssh"
    user        = "null0x"
    private_key = file("~/.ssh/ansible_ed25519")
  }

  ### QOL ###
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R vault:vault /opt/vault",
      "echo 'source /home/null0x/env.sh' >> ~/.bashrc"
    ]
  }

}
