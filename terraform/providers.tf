provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.azure_devops_org_url
  personal_access_token = var.azure_devops_pat
}