
variable "agent_count" {
    description = "count of nodes in the AKS cluster, e.g. 2"
}

variable "agent_size" {
    description = "size of the node in the aks cluster, e.g. Standard_D2s_v3"
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    description = "DNS prefix for this AKS cluster"
}

variable cluster_name {
    description = "Name of the AKS cluster"
}

variable resource_group_name {
    description = "Resource Group Name for AKS"
}

variable vnet_subnet_id {
    description = "Subnet ID to provision the cluster nodes in"
}
variable location {
    default = "westeurope"
}

variable kubernetes_version {
    default = "1.14.5"
}

# azure subscription id
variable "subscription_id" {
    default = "36d3ff36-dc30-4224-9970-6c24b9043705"
}

# azure ad tenant id
variable "tenant_id" {
    default = ""
}

# azure ad tenant id
variable "aks_defaultuser" {
    default = "mamelch"
}

# default tags applied to all resources
variable "environment" {
    default = "production"
}

variable "service_principal_id" {
  default = ""
  type = "string"
}

variable "service_principal_password" {
  default = ""
  type = "string"
}

variable "service_cidr" {
  default = ""
  type = "string"
}


variable "dns_service_ip" {
  default = ""
  type = "string"
}

variable "client_app_id" {
  default = ""
  type = "string"
}

variable "server_app_id" {
  default = ""
  type = "string"
}

variable "server_app_secret" {
  default = ""
  type = "string"
}