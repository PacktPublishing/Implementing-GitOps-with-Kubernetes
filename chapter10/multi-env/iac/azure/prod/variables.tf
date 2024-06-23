variable "environment" {
  description = "The environment in which the resources will be created."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "The location in which the resources will be created."
  type        = string
  default     = "switzerlandnorth"

}

variable "rg" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default     = "gitops-prod-rg"
}
