variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aks_config" {
  description = "Configuration for AKS cluster"
  type = object({
    name                    = string
    kubernetes_version     = string
    vm_size               = string
    os_disk_size_gb       = number
    node_count            = number
    max_pods              = number
    network_plugin        = string
    network_policy        = string
    service_cidr          = string
    dns_service_ip        = string
    docker_bridge_cidr    = string
    enable_auto_scaling   = bool
    min_count            = number
    max_count            = number
    availability_zones    = list(string)
  })
}

variable "subnet_id" {
  description = "ID of the subnet for AKS"
  type        = string
}

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for Linux nodes"
  type        = string
}

variable "enable_user_node_pool" {
  description = "Enable additional user node pool"
  type        = bool
  default     = false
}

variable "user_node_pool_config" {
  description = "Configuration for user node pool"
  type = object({
    vm_size            = string
    os_disk_size_gb    = number
    node_count         = number
    max_pods           = number
    availability_zones = list(string)
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {} 