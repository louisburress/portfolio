# Declare client_id variable
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true  # Mark this as sensitive so it's not displayed in logs
}


variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

# Declare client_secret variable
variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
}

# Declare tenant_id variable
variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

# Declare subscription_id variable
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
