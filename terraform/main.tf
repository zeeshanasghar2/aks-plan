locals {
  resource_group_name = "${var.project_prefix}-rg-${var.environment}"
  aks_cluster_name    = "${var.project_prefix}-aks-${var.environment}"
  # Service Connection names must also be unique per environment
  azurerm_sc_name     = "Azure-SC-${var.environment}"
  aks_sc_name         = "AKS-SC-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_address_space  = var.vnet_address_space
  subnet_address_prefix = var.aks_subnet_address_prefix
  environment         = var.environment
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  cluster_name        = local.aks_cluster_name
  kubernetes_version  = "1.32"
  vnet_subnet_id      = module.networking.subnet_id
  node_count          = var.aks_node_count
  environment         = var.environment
}

# Azure DevOps Project (shared across environments)
resource "azuredevops_project" "project" {
  name               = var.azure_devops_project_name
  description        = "Project for AKS Multi-Env deployment"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

# Azure DevOps Git Repository (shared across environments)
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  name       = var.azure_devops_repo_name
  initialization {
    init_type = "Clean"
  }
}

# Service Connection to Azure Resource Manager (one per environment)
resource "azuredevops_serviceendpoint_azurerm" "azurerm_sc" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = local.azurerm_sc_name
  description           = "Service Connection to Azure for ${var.environment}"
  credentials {
    serviceprincipalid  = module.aks.client_id
    serviceprincipalkey = module.aks.client_secret
  }
  azurerm_spn_tenantid      = module.aks.tenant_id
  azurerm_subscription_id   = module.aks.subscription_id
  azurerm_subscription_name = module.aks.subscription_name
}

# Service Connection to AKS Cluster (one per environment)
resource "azuredevops_serviceendpoint_kubernetes" "aks_sc" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = local.aks_sc_name
  description           = "Service Connection to AKS for ${var.environment}"
  apiserver_url         = module.aks.kube_config.0.host
  authorization_type    = "Kubeconfig"
  kubeconfig {
    kube_config            = module.aks.raw_kube_config
    accept_untrusted_certs = true
  }
}
