
#======================================================================================
# Libvirt connection
#======================================================================================

variable "libvirt_provider_uri" {
  type        = string
  description = "Libvirt provider's URI"
  default     = "qemu:///system"
}

variable "libvirt_resource_pool_name" {
  type        = string
  description = "The libvirt resource pool name"
}

#======================================================================================
# Network
#======================================================================================

variable "network_name" {
  type        = string
  description = "Network name"
}

#======================================================================================
# Kubernetes infrastructure
#======================================================================================

#============================#
# General variables          #
#============================#

variable "vm_user" {
  type        = string
  description = "SSH user for VMs"
  default     = "user"
}

variable "vm_ssh_private_key" {
  type        = string
  description = "Location of private ssh key for VMs"
}

variable "vm_image_source" {
  type        = string
  description = "Image source, which can be path on host's filesystem or URL."
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix added to names of VMs"
  default     = "vm"
}

#============================#
# Master nodes variables     #
#============================#

variable "vm_master_cpu" {
  type        = number
  description = "The number of vCPU allocated to the master node"
  default     = 2
}

variable "vm_master_ram" {
  type        = number
  description = "The amount of RAM allocated to the master node"
  default     = 4096
}

variable "vm_master_storage" {
  type        = number
  description = "The amount of disk (in Bytes) allocated to the master node. Default: 15GB"
  default     = 16106127360
}

variable "vm_master_macs_ips" {
  type        = map(string)
  description = "MAC and IP addresses of master nodes"

  validation {
    condition     = length(var.vm_master_macs_ips) > 0
    error_message = "Variable 'vm_master_macs_ips' is invalid.\nAt least one master node should be defined."
  }
}
