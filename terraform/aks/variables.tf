variable "cluster_name" {
  description = "The name for the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use."
  type        = string
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet to deploy the AKS cluster into."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the AKS cluster."
  type        = number
}