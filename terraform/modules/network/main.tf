# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags

  # DNS Servers - optional
  dns_servers = var.dns_servers
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnet_config

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  # Service Endpoints
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]

  # Delegation for AKS
  dynamic "delegation" {
    for_each = each.key == "aks" ? [1] : []
    content {
      name = "aks-delegation"
      service_delegation {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  for_each = var.subnet_config

  name                = "${each.value.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Default rules
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  # AKS-specific rules
  dynamic "security_rule" {
    for_each = each.key == "aks" ? [1] : []
    content {
      name                       = "AllowAKSRequired"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range         = "*"
      destination_port_ranges   = ["443", "9000", "22"]
      source_address_prefix     = "*"
      destination_address_prefix = "*"
    }
  }
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.subnet_config

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# Route Table
resource "azurerm_route_table" "rt" {
  name                = "${var.vnet_name}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Force tunnel all outbound traffic through Azure Firewall
  dynamic "route" {
    for_each = var.enable_forced_tunneling ? [1] : []
    content {
      name                   = "ForceInternetThroughFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type         = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }
}

# Associate Route Table with Subnets
resource "azurerm_subnet_route_table_association" "rt_association" {
  for_each = var.subnet_config

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.rt.id
}

# DDoS Protection Plan (Optional)
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count = var.enable_ddos_protection ? 1 : 0

  name                = "${var.vnet_name}-ddos"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "${var.vnet_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
} 