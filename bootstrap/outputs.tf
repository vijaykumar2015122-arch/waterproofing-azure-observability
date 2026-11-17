output "resource_group_name" {
  description = "Resource group containing Terraform state storage"
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Azure Storage Account used for Terraform state"
  value       = azurerm_storage_account.state.name
}

output "container_name" {
  description = "Blob container used for Terraform state"
  value       = azurerm_storage_container.state.name
}
