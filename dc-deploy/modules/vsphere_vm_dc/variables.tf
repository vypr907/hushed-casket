variable "datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster name"
  type        = string
}

variable "network" {
  description = "vSphere network name"
  type        = string
}

variable "vm_name" {
  description = "Name of the Domain Controller VM"
  type        = string
}

variable "iso_path" {
  description = "Path to Windows Server ISO (datastore or local)"
  type        = string
}

variable "floppy_path" {
  description = "Path to floppy image with unattend scripts"
  type        = string
}

variable "vm_fqdn" {
  description = "Fully qualified domain name for the Domain Controller"
  type        = string
}

variable "vm_expected_ip" {
  description = "Expected IP address for DNS verification"
  type        = string
}

variable "iso_path_is_datastore" {
  description = "Whether the ISO path is in the vSphere datastore (true) or local (false)"
  type        = bool
  default     = true
}
