variable "resource_group_name" {}
variable "location" {}
# variable "subnet_name" {}
variable "aks_cluster_name" {}
variable "node_count" {}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "subnet_prefixes" {
  type        = map(string)
  description = "Map for subnet prefixes for Web, App, and DB"
  default = {
    web  = "10.0.1.0/24"
    app  = "10.0.2.0/24"
    db   = "10.0.3.0/24"
  }
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}