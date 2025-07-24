variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_config" {
  description = "Configuration for subnets"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "enable_forced_tunneling" {
  description = "Enable forced tunneling through Azure Firewall"
  type        = bool
  default     = false
}

variable "firewall_private_ip" {
  description = "Private IP of Azure Firewall for forced tunneling"
  type        = string
  default     = null
}

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Plan"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {} 