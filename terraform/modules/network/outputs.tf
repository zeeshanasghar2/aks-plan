output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "route_table_id" {
  description = "ID of the route table"
  value       = azurerm_route_table.rt.id
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = azurerm_private_dns_zone.aks.id
}

output "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan"
  value       = var.enable_ddos_protection ? azurerm_network_ddos_protection_plan.ddos[0].id : null
} 