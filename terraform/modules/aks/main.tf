# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_config.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix         = var.aks_config.name
  kubernetes_version = var.aks_config.kubernetes_version
  tags               = var.tags

  # Default Node Pool
  default_node_pool {
    name                = "default"
    vm_size             = var.aks_config.vm_size
    os_disk_size_gb     = var.aks_config.os_disk_size_gb
    node_count          = var.aks_config.node_count
    max_pods            = var.aks_config.max_pods
    vnet_subnet_id      = var.subnet_id
    availability_zones  = var.aks_config.availability_zones
    enable_auto_scaling = var.aks_config.enable_auto_scaling
    min_count          = var.aks_config.enable_auto_scaling ? var.aks_config.min_count : null
    max_count          = var.aks_config.enable_auto_scaling ? var.aks_config.max_count : null
    
    # Node Pool Tags
    tags = merge(var.tags, {
      "nodepool-type" = "system"
      "environment"   = var.environment
    })
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # Network Profile
  network_profile {
    network_plugin     = var.aks_config.network_plugin
    network_policy     = var.aks_config.network_policy
    service_cidr       = var.aks_config.service_cidr
    dns_service_ip     = var.aks_config.dns_service_ip
    docker_bridge_cidr = var.aks_config.docker_bridge_cidr
    load_balancer_sku  = "standard"
  }

  # RBAC
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      azure_rbac_enabled = true
    }
  }

  # Add-ons
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_id
    }

    azure_policy {
      enabled = true
    }

    azure_keyvault_secrets_provider {
      enabled = true
    }
  }

  # Auto-upgrade
  automatic_channel_upgrade = "stable"
  
  # Maintenance Window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [21, 22, 23]
    }
  }

  # Linux Profile
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  count = var.enable_user_node_pool ? 1 : 0

  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size              = var.user_node_pool_config.vm_size
  os_disk_size_gb      = var.user_node_pool_config.os_disk_size_gb
  node_count           = var.user_node_pool_config.node_count
  max_pods             = var.user_node_pool_config.max_pods
  vnet_subnet_id       = var.subnet_id
  availability_zones   = var.user_node_pool_config.availability_zones
  enable_auto_scaling  = var.user_node_pool_config.enable_auto_scaling
  min_count           = var.user_node_pool_config.enable_auto_scaling ? var.user_node_pool_config.min_count : null
  max_count           = var.user_node_pool_config.enable_auto_scaling ? var.user_node_pool_config.max_count : null
  
  # Node Pool Tags
  tags = merge(var.tags, {
    "nodepool-type" = "user"
    "environment"   = var.environment
  })
}

# Role Assignments
resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.aks_config.name}-diagnostics"
  target_resource_id        = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_id

  log {
    category = "kube-apiserver"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "kube-audit"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 30
    }
  }
} 