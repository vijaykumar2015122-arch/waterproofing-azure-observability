# Main Virtual Network

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
}

# Subnet for Ubuntu VM and K3s

resource "azurerm_subnet" "vm" {
  name                 = var.vm_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.1.0/24"]
}

# Dedicated delegated subnet for PostgreSQL

resource "azurerm_subnet" "postgres" {
  name                 = var.postgres_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.2.0/24"]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Private DNS zone for PostgreSQL

resource "azurerm_private_dns_zone" "postgres" {
  name                = "waterproofing.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

# Connect the private DNS zone to our VNet

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-waterproofing-postgres"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Network Security Group for the VM subnet

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-waterproofing-obs-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH-From-Admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_source_ip
    destination_address_prefix = "*"
  }

  tags = {
    purpose = "observability-vm-network-security"
  }
}

# Associate NSG with VM subnet

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}
