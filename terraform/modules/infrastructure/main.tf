# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Network Module
module "network" {
  source = "../network"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_config      = var.subnet_config
  tags               = var.tags
}

# AKS Module
module "aks" {
  source = "../aks"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  aks_config         = var.aks_config
  subnet_id          = module.network.subnet_ids["aks"]
  log_analytics_id   = module.monitoring.log_analytics_id
  tags               = var.tags

  depends_on = [
    module.network,
    module.monitoring
  ]
}

# Container Registry
module "acr" {
  source = "../acr"

  resource_group_name        = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  acr_config                = var.acr_config
  aks_principal_id          = module.aks.principal_id
  tags                      = var.tags
}

# Key Vault
module "key_vault" {
  source = "../key_vault"

  resource_group_name     = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  key_vault_config       = var.key_vault_config
  aks_principal_id       = module.aks.principal_id
  tags                   = var.tags
}

# Monitoring
module "monitoring" {
  source = "../monitoring"

  resource_group_name        = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  log_analytics_config      = var.log_analytics_config
  monitoring_config         = var.monitoring_config
  tags                      = var.tags
}

# Backup (Production Only)
module "backup" {
  source = "../backup"
  count  = var.environment == "prod" ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  backup_config      = var.backup_config
  aks_id             = module.aks.cluster_id
  tags               = var.tags
}

# High Availability (Production Only)
module "high_availability" {
  source = "../high_availability"
  count  = var.environment == "prod" ? 1 : 0

  resource_group_name        = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  ha_config                 = var.high_availability_config
  aks_id                    = module.aks.cluster_id
  tags                      = var.tags
}

# Security
module "security" {
  source = "../security"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  security_config    = var.security_config
  aks_id             = module.aks.cluster_id
  tags               = var.tags
} 