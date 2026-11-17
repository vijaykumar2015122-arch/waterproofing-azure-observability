resource "azurerm_postgresql_flexible_server" "main" {
  name                = var.postgres_server_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  version                = "16"
  delegated_subnet_id    = azurerm_subnet.postgres.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  sku_name   = var.postgres_sku_name
  storage_mb = var.postgres_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled = false

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

  tags = {
    project     = "waterproofing-azure-observability"
    environment = "learning"
    managed_by  = "terraform"
  }
}

# Logical database inside PostgreSQL Flexible Server

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "waterproofingdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
