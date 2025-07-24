output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config
  sensitive = true
}

output "raw_kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "identity_client_id" {
  description = "The client ID of the user-assigned identity."
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "identity_principal_id" {
  description = "The principal ID of the user-assigned identity."
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}