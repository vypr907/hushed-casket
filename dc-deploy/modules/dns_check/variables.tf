variable "vm_fqdn" {
  description = "The fully qualified domain name of the VM to check."
  type        = string
}

variable "vm_expected_ip" {
  description = "The expected IP address for the VM to verify against DNS."
  type        = string
}