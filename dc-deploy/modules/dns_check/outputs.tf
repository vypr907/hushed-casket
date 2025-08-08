output "dns_check_completed" {
  value = "DNS check completed for ${var.vm_fqdn} with expected IP ${var.vm_expected_ip}"
}