output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => azurerm_linux_virtual_machine.machine[key].public_ip_address
  }
}

output "domains" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => azurerm_public_ip.pip[key].fqdn
  }
}

resource "local_file" "backup" {
  for_each = toset(var.create_ssh_hosts ? var.machines : [])
  content = templatefile("${path.root}/backup/hosts.tmpl", {
    domains = [
      for key in var.machines :
      azurerm_public_ip.pip[key].fqdn
    ]
  })
  filename = "${path.root}/backup/hosts"
  file_permission = 644
}