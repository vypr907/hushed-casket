terraform {
    required_version = ">= 1.3.0"
    required_providers {
        null = {
            source  = "hashicorp/null"
            version = ">= 3.2.0"
        }
    }
}
resource "null_resource" "dns_check" {
  provisioner "local-exec" {
    command = "nslookup ${var.vm_fqdn} | grep -q ${var.vm_expected_ip}"
    interpreter = ["bash", "-c"]
  }
}