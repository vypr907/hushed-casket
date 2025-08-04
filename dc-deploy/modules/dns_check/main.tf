resource "null_resource" "dns_check" {
  provisioner "local-exec" {
    command = "nslookup ${var.vm_fqdn} | grep -q ${var.vm_expected_ip}"
    interpreter = ["bash", "-c"]
  }
}