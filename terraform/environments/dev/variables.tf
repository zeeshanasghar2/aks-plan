variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "alert_email_receivers" {
  description = "List of email addresses for alerts"
  type        = list(string)
} 