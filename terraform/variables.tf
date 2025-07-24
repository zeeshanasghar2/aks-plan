variable "project_prefix" {
  description = "A prefix for all resources to ensure uniqueness."
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "The deployment environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "aks_node_count" {
  description = "The number of nodes in the AKS cluster."
  type        = number
  default     = 1
}

variable "azure_devops_org_url" {
  description = "The URL of the Azure DevOps organization."
  type        = string
}

variable "azure_devops_pat" {
  description = "The Personal Access Token for Azure DevOps."
  type        = string
  sensitive   = true
}

variable "azure_devops_project_name" {
  description = "The name of the Azure DevOps project."
  type        = string
  default     = "AKS-Multi-Env-Project"
}

variable "azure_devops_repo_name" {
  description = "The name of the Azure DevOps Git repository."
  type        = string
  default     = "aks-helm-app-multi-env"
}
