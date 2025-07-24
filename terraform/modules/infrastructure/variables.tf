variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_config" {
  description = "Configuration for subnets"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "aks_config" {
  description = "Configuration for AKS cluster"
  type = object({
    name                    = string
    kubernetes_version     = string
    vm_size               = string
    os_disk_size_gb       = number
    node_count            = number
    max_pods              = number
    network_plugin        = string
    network_policy        = string
    service_cidr          = string
    dns_service_ip        = string
    docker_bridge_cidr    = string
    enable_auto_scaling   = bool
    min_count            = number
    max_count            = number
    enable_node_public_ip = bool
    availability_zones    = list(string)
  })
}

variable "log_analytics_config" {
  description = "Configuration for Log Analytics"
  type = object({
    name              = string
    retention_in_days = number
  })
}

variable "acr_config" {
  description = "Configuration for Azure Container Registry"
  type = object({
    name                     = string
    sku                      = string
    admin_enabled           = bool
    georeplication_locations = list(string)
  })
}

variable "key_vault_config" {
  description = "Configuration for Azure Key Vault"
  type = object({
    name                    = string
    sku_name               = string
    soft_delete_enabled    = bool
    purge_protection_enabled = bool
  })
}

variable "monitoring_config" {
  description = "Configuration for monitoring"
  type = object({
    metrics_retention_in_days = number
    enable_alerts            = bool
    action_group_name        = string
    action_group_short_name  = string
    email_receivers         = list(string)
  })
}

variable "backup_config" {
  description = "Configuration for backup (Production only)"
  type = object({
    enabled         = bool
    retention_days  = number
    backup_schedule = string
    geo_redundant   = bool
  })
  default = null
}

variable "high_availability_config" {
  description = "Configuration for high availability (Production only)"
  type = object({
    zone_redundant     = bool
    availability_zones = list(string)
    disaster_recovery = bool
    failover_location = string
  })
  default = null
}

variable "security_config" {
  description = "Configuration for security features"
  type = object({
    enable_pod_security_policy = bool
    enable_network_policy     = bool
    enable_azure_policy      = bool
    enable_key_vault_secrets = bool
    enable_disk_encryption   = bool
  })
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {} 