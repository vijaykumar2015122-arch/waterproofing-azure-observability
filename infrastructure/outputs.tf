output "resource_group_name" {
  description = "Main Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Observability Ubuntu VM name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP used for restricted SSH access"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_private_ip" {
  description = "Private IP of the observability VM"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}

output "postgres_server_name" {
  description = "PostgreSQL Flexible Server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "postgres_server_fqdn" {
  description = "Private PostgreSQL server hostname"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database_name" {
  description = "Logical PostgreSQL database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "observability_disk_name" {
  description = "Additional Azure managed disk"
  value       = azurerm_managed_disk.observability.name
}
