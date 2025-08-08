variable "vsphere_user" {
  description = "Username for vSphere"
  type        = string
}

variable "vsphere_password" {
  description = "Password for vSphere"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
}

variable "datacenter" {
  description = "Name of the vSphere datacenter"
  type        = string
}

variable "datastore" {
  description = "Name of the vSphere datastore"
  type        = string
}

variable "host" {
  description = "Name of the vSphere host"
  type        = string
}

variable "local_host" {
  description = "Local host IP address for temporary hardcoding"
  type        = string
}

variable "network" {
  description = "Name of the vSphere network"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "iso_path" {
  description = "Path to the ISO file for the VM (datastore path or local path)"
  type        = string
}

variable "iso_path_is_datastore" {
  description = "Boolean indicating if the ISO path is a datastore path"
  type        = bool
  default     = false
}

variable "vm_fqdn" {
  description = "Fully qualified domain name of the VM"
  type        = string
}

variable "vm_expected_ip" {
  description = "Expected IP address of the VM"
  type        = string
}

variable "vm_guest_id" {
  description = "Guest ID for the VM"
  type        = string
  default     = "windows2019srv_64Guest"
}

variable "domain_name" {
  description = "Domain name for the Domain Controller VM"
  type        = string
  default = "example.com"
}

variable "vm_admin_user" {
  description = "Admin username for the VM"
  type        = string
  default     = "Administrator"
}
variable "vm_admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd!"
}