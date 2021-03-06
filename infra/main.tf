#=====================================================================================
# Provider specific
#=====================================================================================

# Sets libvirt provider's uri #
provider "libvirt" {
  uri = var.libvirt_provider_uri
}

#======================================================================================
# Modules
#======================================================================================

# Creates master nodes #
module "master_module" {
  source = "./modules/vm"

  count = length(var.vm_master_macs_ips)

  # Variables from general resources #
  resource_pool_name = var.libvirt_resource_pool_name
  base_volume_id     = libvirt_volume.base_volume.id
  cloud_init_id      = libvirt_cloudinit_disk.cloud_init.id

  # Master node specific variables #
  vm_index           = count.index + 1
  vm_type            = "master"
  vm_user            = var.vm_user
  vm_ssh_private_key = var.vm_ssh_private_key
  vm_network_name    = var.network_name
  vm_name_prefix     = var.vm_name_prefix
  vm_cpu             = var.vm_master_cpu
  vm_ram             = var.vm_master_ram
  vm_storage         = var.vm_master_storage
  vm_mac             = keys(var.vm_master_macs_ips)[count.index]
  vm_address         = values(var.vm_master_macs_ips)[count.index]

  # Dependancy takes care that resource pool is not removed before volumes are #
  depends_on = [
    libvirt_volume.base_volume
  ]
}

#======================================================================================
# General Resources
#======================================================================================

#================================
# Base volume
#================================

# Creates base OS image for nodes in a cluster #
resource "libvirt_volume" "base_volume" {
  name   = "base_volume"
  pool   = var.libvirt_resource_pool_name
  source = var.vm_image_source
}

#================================
# Cloud-init
#================================

# Public ssh key for vm (it is directly injected in cloud-init configuration) #
data "template_file" "public_ssh_key" {
  template = file("${var.vm_ssh_private_key}.pub")
}

# Cloud-init configuration template #
data "template_file" "cloud_init_tpl" {
  template = file("templates/cloud_init.tpl")

  vars = {
    user           = var.vm_user
    ssh_public_key = data.template_file.public_ssh_key.rendered
  }
}

# Creates cloud-init configuration file from template #
resource "local_file" "cloud_init_file" {
  content  = data.template_file.cloud_init_tpl.rendered
  filename = "config/cloud_init.cfg"
}

# Initializes cloud-init disk for user data#
resource "libvirt_cloudinit_disk" "cloud_init" {
  name           = "cloud-init.iso"
  pool           = var.libvirt_resource_pool_name
  user_data      = data.template_file.cloud_init_tpl.rendered
}
