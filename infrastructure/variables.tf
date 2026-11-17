# General Azure configuration

variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Main observability resource group"
  type        = string
  default     = "rg-waterproofing-observability"
}

# Virtual Machine configuration

variable "vm_name" {
  description = "Observability Linux VM name"
  type        = string
  default     = "vm-waterproofing-obs"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Linux VM administrator username"
  type        = string
  default     = "vijayadmin"
}

variable "admin_source_ip" {
  description = "Public IP allowed to access VM through SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_source_ip, 0))
    error_message = "Provide a valid IPv4 CIDR, preferably your public IP followed by /32."
  }
}

variable "admin_ssh_public_key" {
  description = "SSH public key used to access the Linux VM"
  type        = string
  sensitive   = true
}

# Virtual Network configuration

variable "vnet_name" {
  description = "Observability Virtual Network name"
  type        = string
  default     = "vnet-waterproofing-obs"
}

variable "vnet_address_space" {
  description = "Virtual Network address range"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "vm_subnet_name" {
  description = "Subnet for the K3s VM"
  type        = string
  default     = "snet-observability-vm"
}

variable "postgres_subnet_name" {
  description = "Delegated subnet for PostgreSQL"
  type        = string
  default     = "snet-postgresql"
}

# PostgreSQL configuration

variable "postgres_server_name" {
  description = "PostgreSQL Flexible Server name"
  type        = string
  default     = "psql-waterproofing-obs"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "wpadminuser"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgres_admin_password) >= 12
    error_message = "PostgreSQL password must contain at least 12 characters."
  }
}

variable "postgres_sku_name" {
  description = "PostgreSQL compute SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage allocation in MB"
  type        = number
  default     = 32768
}
