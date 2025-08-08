variable "datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "host" {
  description = "vSphere host name"
  type        = string
}

variable "local_host" {
  description = "Local host IP address for temporary hardcoding"
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

variable "vm_admin_user" {
  description = "vSphere username"
  type        = string
}

variable "vm_admin_password" {
  description = "vSphere password"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Domain Controller"
  type        = string
}