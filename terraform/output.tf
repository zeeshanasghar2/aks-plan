output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "azure_devops_project_url" {
  value = azuredevops_project.project.id
}

output "azure_devops_git_repo_url" {
  value = azuredevops_git_repository.repo.remote_url
}

output "kubernetes_service_connection_name" {
  description = "The name of the Azure DevOps Service Connection created for the AKS cluster in this environment."
  value       = local.aks_sc_name
}