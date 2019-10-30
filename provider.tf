provider "azurerm" {
}

provider "azuread" {
}

provider "helm" {
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.2"
}

#configure your backend
#use an environment variable to configure the access key to it:
#linux: export ARM_ACCESS_KEY=$(az storage account keys list --resource-group <RESOURCEGROUP> --account-name <ACCOUNTNAME> --query [0].value -o tsv)
#win: $env:ARM_ACCESS_KEY=az storage account keys list --resource-group <RESOURCEGROUP> --account-name <ACCOUNTNAME> --query [0].value -o tsv
terraform {
  backend "azurerm" {
    storage_account_name = "mamelchtf"
    container_name       = "aks"
    key                  = "prod.terraform.tfstate"
  }
}

