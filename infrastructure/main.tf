######### LOCAL VARIABLES ###################################################################################
locals {
  flepmep = {
    for category, child in module.deployment : category => zipmap(flatten([child.name]), (flatten(child.ipv4)))
  }
  flatmap = zipmap(flatten(values(module.deployment)[*].server_name), flatten(values(module.deployment)[*].server_ipv4))


  merged_map = {
    for tpl_id, tpl_conf in var.templates : tpl_id => {
      base_file       = tpl_conf.base_file
      template_source = file("${tpl_conf.template_source}")
      variables = merge(tpl_conf.variables, {
        ansible_map  = local.flepmep
        aws_user_map = module.aws_bootstrap.user
        region       = var.provider_aws.region
        aws_kms_map  = module.aws_bootstrap.kms
        dirty_map    = local.flatmap
      })
      local_destination = tpl_conf.local_destination
      with_node_id      = tpl_conf.with_node_id
    }
  }

  merged_ansible_map = {
    for x, y in var.ansible_templates : x => {
      base_file         = y.base_file
      template_source   = file("${y.template_source}")
      local_destination = y.local_destination
      with_node_id      = y.with_node_id
      variables = merge(y.variables, {
        ansible_map = local.flepmep
      })
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
  source           = "github.com/null0xeth/terraform_pve_cloud_init"
  cloud-init       = var.cloud-init
  provider_aws     = var.provider_aws
  provider_proxmox = var.provider_proxmox
}

######### MODULE: MODULES/VM_CLUSTER ########################################################################
module "deployment" {
  source   = "github.com/null0xeth/terraform_pve_vm"
  for_each = var.cluster_spec

  auth_bundle = {
    username = var.vm_username
    password = var.vm_password
    ssh_keys = var.vm_ssh_keys
  }

  cloud_init_id    = module.cloud-init.id
  cluster_spec     = each.value
  resource_tags    = var.resource_tags
  provider_aws     = var.provider_aws
  provider_proxmox = var.provider_proxmox
  providers = {
    aws     = aws
    proxmox = proxmox
  }
}

#########  MODULE: BASE/TEMPLATE_FILE #######################################################################
module "render_ansible_templates" {
  source    = "github.com/null0xeth/terraform_template_renderer"
  templates = local.merged_ansible_map
}

#########  RESOURCES: PROVISIONING ##########################################################################
module "render_provisioning_templates" {
  source    = "github.com/null0xeth/terraform_template_renderer"
  for_each  = local.flepmep.vault_server
  templates = local.merged_map
  node_id   = each.key
}

resource "null_resource" "provisioning" {
  for_each = local.flepmep.vault_server

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
  for_each = local.flepmep.vault_server

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
