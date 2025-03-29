terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
  }
}

resource "helm_release" "web" {
  name       = "web"
  chart      = "../web"  # Path to your Web chart directory
  version    = "0.1.0"
  namespace  = "default"
  # timeout    = 1200  # Timeout increased to 1200 seconds (20 minutes)

}

resource "helm_release" "api" {
  name       = "api"
  chart      = "../api"  # Path to your API chart directory
  version    = "0.1.0"
  namespace  = "default"
  # timeout    = 1200  # Timeout increased to 1200 seconds (20 minutes)

}

resource "helm_release" "mysql" {
  name       = "mysql"
  chart      = "../mysql"  # Path to your MySQL chart directory
  version    = "0.1.0"
  namespace  = "default"
}
