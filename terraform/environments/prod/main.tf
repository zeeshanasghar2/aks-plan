module "prod_infrastructure" {
  source = "../../modules/infrastructure"

  environment = "prod"
  location    = var.location
  prefix      = var.prefix

  # Resource Group
  resource_group_name = "${var.prefix}-prod-rg"

  # Network Configuration
  vnet_name          = "${var.prefix}-prod-vnet"
  vnet_address_space = ["10.2.0.0/16"]
  subnet_config = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = ["10.2.0.0/20"]
    }
    agw = {
      name             = "agw-subnet"
      address_prefixes = ["10.2.16.0/24"]
    }
  }

  # AKS Configuration
  aks_config = {
    name                       = "${var.prefix}-prod-aks"
    kubernetes_version        = "1.27"
    vm_size                  = "Standard_D4s_v3"
    os_disk_size_gb          = 100
    node_count               = 3
    max_pods                 = 100
    network_plugin           = "azure"
    network_policy           = "calico"
    service_cidr             = "10.0.0.0/16"
    dns_service_ip           = "10.0.0.10"
    docker_bridge_cidr       = "172.17.0.1/16"
    enable_auto_scaling      = true
    min_count               = 3
    max_count               = 10
    enable_node_public_ip    = false
    availability_zones       = ["1", "2", "3"]
  }

  # Log Analytics
  log_analytics_config = {
    name              = "${var.prefix}-prod-logs"
    retention_in_days = 90
  }

  # Container Registry
  acr_config = {
    name                     = replace("${var.prefix}prodacr", "-", "")
    sku                      = "Premium"
    admin_enabled           = false
    georeplication_locations = var.acr_georeplication_locations
  }

  # Key Vault
  key_vault_config = {
    name                    = "${var.prefix}-prod-kv"
    sku_name               = "premium"
    soft_delete_enabled    = true
    purge_protection_enabled = true
  }

  # Monitoring
  monitoring_config = {
    metrics_retention_in_days = 90
    enable_alerts            = true
    action_group_name        = "${var.prefix}-prod-ag"
    action_group_short_name  = "prodag"
    email_receivers         = var.alert_email_receivers
  }

  # Backup
  backup_config = {
    enabled                = true
    retention_days         = 30
    backup_schedule        = "0 1 * * *"
    geo_redundant          = true
  }

  # High Availability
  high_availability_config = {
    zone_redundant         = true
    availability_zones     = ["1", "2", "3"]
    disaster_recovery     = true
    failover_location     = var.dr_location
  }

  # Security
  security_config = {
    enable_pod_security_policy = true
    enable_network_policy     = true
    enable_azure_policy      = true
    enable_key_vault_secrets = true
    enable_disk_encryption   = true
  }

  # Tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Owner       = var.owner
    Tier        = "Production"
    Compliance  = "SOC2"
  }
} 