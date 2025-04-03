resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet" "web_subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = [var.subnet_prefixes["web"]]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = [var.subnet_prefixes["app"]]
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = [var.subnet_prefixes["db"]]
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "thisdnsname"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.app_subnet.id

  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
    network_policy    = "calico"
    dns_service_ip    = "10.2.0.10"
    service_cidr      = "10.2.0.0/24"
  }
  provisioner "local-exec" {
  command = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks_cluster.name} --overwrite-existing"
}

}
#1 version 
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope               = azurerm_container_registry.acr.id
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${azurerm_container_registry.acr.name}
      docker build -t ${azurerm_container_registry.acr.login_server}/my-image:v2 .
      docker push ${azurerm_container_registry.acr.login_server}/my-image:v2
      docker build -t ${azurerm_container_registry.acr.login_server}/my-image:v1 .
      docker push ${azurerm_container_registry.acr.login_server}/my-image:v1
    EOT
  }
  

  triggers = {
    always_run = "${timestamp()}" # Forces re-run on every apply
  }
}

# 2 version
# resource "azurerm_container_registry" "acr" {
#   name                = var.acr_name
#   resource_group_name = azurerm_resource_group.aks_rg.name
#   location            = var.location
#   sku                 = "Standard"
#   admin_enabled       = true  # ✅ Enable Admin Credentials
# }

# data "azurerm_container_registry" "acr" {
#   name                = azurerm_container_registry.acr.name
#   resource_group_name = azurerm_resource_group.aks_rg.name
# }

# resource "kubernetes_secret" "acr_secret" {
#   metadata {
#     name = "acr-secret"
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${data.azurerm_container_registry.acr.login_server}" = {
#           "username" = data.azurerm_container_registry.acr.admin_username
#           "password" = data.azurerm_container_registry.acr.admin_password
#         }
#       }
#     })
#   }
# }
