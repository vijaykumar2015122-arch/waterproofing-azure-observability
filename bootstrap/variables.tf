variable "location" {
  description = "Azure region for Terraform state resources"
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Resource group that stores Terraform state resources"
  type        = string
  default     = "rg-waterproofing-tfstate"
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name (3-24 lowercase letters and numbers)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must contain 3-24 lowercase letters or numbers only."
  }
}

variable "container_name" {
  description = "Blob container used to store Terraform state"
  type        = string
  default     = "tfstate"
}
