locals {
  vm_hostname = "${var.vm_name_prefix}-${var.vm_type}-${var.vm_index}"
}

# Creates volume for new virtual machine #
resource "libvirt_volume" "vm_volume" {
  name           = "${local.vm_hostname}.qcow2"
  pool           = var.resource_pool_name
  base_volume_id = var.base_volume_id
  size           = var.vm_storage
  format         = "qcow2"
}

# Creates virtual machine #
resource "libvirt_domain" "vm_domain" {

  # General configuration #
  name      = local.vm_hostname
  vcpu      = var.vm_cpu
  memory    = var.vm_ram
  autostart = true

  cloudinit = var.cloud_init_id

  # Network configuration #
  network_interface {
    network_name   = var.vm_network_name
    hostname       = local.vm_hostname
    addresses      = [var.vm_address]
    mac            = var.vm_mac
    wait_for_lease = true
  }

  # Storage configuration #
  disk {
    volume_id = libvirt_volume.vm_volume.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  # Connect to VM using SSH and wait until cloud-init finishes tasks #
  provisioner "remote-exec" {

    connection {
      host        = self.network_interface.0.addresses.0
      type        = "ssh"
      user        = var.vm_user
      private_key = file(var.vm_ssh_private_key)
    }

    inline = [
      "while ! grep \"Cloud-init .* finished\" /var/log/cloud-init.log; do echo \"$(date -Ins) Waiting for cloud-init to finish\"; sleep 2; done"
    ]
  }

}
