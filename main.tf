resource "azurerm_resource_group" "rg-aks" {
  name     = "aks"
  location = "West Europe"
}

resource "random_string" "aks" {
  length  = 6
  special = false
  lower   = true
  upper   = false
  number  = false
}

resource "azurerm_virtual_network" "vnet-onprem" {
  name                = "onprem"
  location            = "${azurerm_resource_group.rg-aks.location}"
  resource_group_name = "${azurerm_resource_group.rg-aks.name}"
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_virtual_network" "vnet-cloud" {
  name                = "cloud"
  location            = "${azurerm_resource_group.rg-aks.location}"
  resource_group_name = "${azurerm_resource_group.rg-aks.name}"
  address_space       = ["44.130.0.0/16", "10.251.40.0/22"]
}

resource "azurerm_subnet" "cloud-private" {
  name                 = "private-external"
  address_prefix       = "10.251.40.0/22"
  resource_group_name  = "${azurerm_resource_group.rg-aks.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet-cloud.name}"
}

resource "azurerm_subnet" "cloud-public" {
  name                 = "private-internal"
  address_prefix       = "44.130.42.0/24"
  resource_group_name  = "${azurerm_resource_group.rg-aks.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet-cloud.name}"
}

module "aks" {
  source                     = "./modules/aks"
  cluster_name               = "aks"                                   #name of the cluster
  vnet_subnet_id             = "${azurerm_subnet.cloud-private.id}"    #the subnet for the nodes
  service_cidr               = "10.255.0.0/16"                         #the service cidr - must not overlap with any subnet!
  dns_service_ip             = "10.255.0.10"                           #the dns service for k8s - must be in the service cidr
  resource_group_name        = "${azurerm_resource_group.rg-aks.name}" #the rg for the cluster object
  dns_prefix                 = "aks-${random_string.aks.result}"       #dns prefix for the cluster
  agent_count                = "3"                                     #how many nodes
  agent_size                 = "Standard_D2s_v3"                       #node size, see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
  kubernetes_version         = "1.14.7"                                #kubernetes version - must be in the list 'az aks get-versions -l westeurope -o table'
  service_principal_id       = "${var.service_principal_id}"           #the service principal id for the cluster
  service_principal_password = "${var.service_principal_password}"     #the service principal password for the cluster
  client_app_id              = ""                                      #(optional for RBAC integration) the Azure AD client application id 
  server_app_id              = ""                                      #(optional for RBAC integration) the Azure AD server application id for RBAC integration
  server_app_secret          = ""                                      #(optional for RBAC integration) the secret that was created for the Azure AD Server application for RBAC integration
}

# merge kubeconfig from the cluster so you can use kubectl
resource "null_resource" "get-credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials --overwrite-existing --resource-group ${azurerm_resource_group.rg-aks.name} --name aks"
  }
  depends_on = ["module.aks"]
}
