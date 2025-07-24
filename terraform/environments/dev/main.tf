module "dev_infrastructure" {
  source = "../../modules/infrastructure"

  environment = "dev"
  location    = var.location
  prefix      = var.prefix

  # Resource Group
  resource_group_name = "${var.prefix}-dev-rg"

  # Network Configuration
  vnet_name          = "${var.prefix}-dev-vnet"
  vnet_address_space = ["10.1.0.0/16"]
  subnet_config = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = ["10.1.0.0/20"]
    }
    agw = {
      name             = "agw-subnet"
      address_prefixes = ["10.1.16.0/24"]
    }
  }

  # AKS Configuration
  aks_config = {
    name                       = "${var.prefix}-dev-aks"
    kubernetes_version        = "1.27"
    vm_size                  = "Standard_D2s_v3"
    os_disk_size_gb          = 50
    node_count               = 2
    max_pods                 = 50
    network_plugin           = "azure"
    network_policy           = "calico"
    service_cidr             = "10.0.0.0/16"
    dns_service_ip           = "10.0.0.10"
    docker_bridge_cidr       = "172.17.0.1/16"
    enable_auto_scaling      = true
    min_count               = 1
    max_count               = 3
    enable_node_public_ip    = false
    availability_zones       = ["1", "2", "3"]
  }

  # Log Analytics
  log_analytics_config = {
    name              = "${var.prefix}-dev-logs"
    retention_in_days = 30
  }

  # Container Registry
  acr_config = {
    name                     = replace("${var.prefix}devacr", "-", "")
    sku                      = "Standard"
    admin_enabled           = false
    georeplication_locations = []
  }

  # Key Vault
  key_vault_config = {
    name                    = "${var.prefix}-dev-kv"
    sku_name               = "standard"
    soft_delete_enabled    = true
    purge_protection_enabled = false
  }

  # Monitoring
  monitoring_config = {
    metrics_retention_in_days = 30
    enable_alerts            = true
    action_group_name        = "${var.prefix}-dev-ag"
    action_group_short_name  = "devag"
    email_receivers         = var.alert_email_receivers
  }

  # Tags
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Owner       = var.owner
  }
} 