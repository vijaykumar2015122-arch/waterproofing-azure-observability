# Public IP for SSH access

resource "azurerm_public_ip" "vm" {
  name                = "pip-waterproofing-obs-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network interface for Ubuntu VM

resource "azurerm_network_interface" "vm" {
  name                = "nic-waterproofing-obs-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# Ubuntu Linux VM with K3s installation through cloud-init

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-waterproofing-obs"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }


  tags = {
    project     = "waterproofing-azure-observability"
    environment = "learning"
    managed_by  = "terraform"
  }
}

# Separate 64 GB managed disk for K3s data

resource "azurerm_managed_disk" "observability" {
  name                 = "disk-waterproofing-obs-data"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 64
}

# Attach data disk to Ubuntu VM

resource "azurerm_virtual_machine_data_disk_attachment" "observability" {
  managed_disk_id    = azurerm_managed_disk.observability.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = 0
  caching            = "ReadWrite"
}


# Install K3s only after the Azure data disk is attached

resource "azurerm_virtual_machine_extension" "install_k3s" {
  name                 = "install-k3s"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    script = base64encode(
      file("${path.module}/cloud-init/install-k3s.sh")
    )
  })

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.observability
  ]
}
