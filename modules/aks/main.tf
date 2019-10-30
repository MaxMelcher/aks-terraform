# https://www.terraform.io/docs/providers/azurerm/d/kubernetes_cluster.html
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.cluster_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kubernetes_version}"


  linux_profile {
    admin_username = "${var.aks_defaultuser}"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.agent_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
    max_pods        = 100
    vnet_subnet_id  = "${var.vnet_subnet_id}"
    type            = "VirtualMachineScaleSets" #VMSS (will soon be default!)
  }

  role_based_access_control {
    enabled = true

    dynamic "azure_active_directory" {
      #if client_app_id is provided, add the RBAC integration
      for_each = var.client_app_id == "" ? [] : [1]
      content {
        client_app_id     = "${var.client_app_id}"
        server_app_id     = "${var.server_app_id}"
        server_app_secret = "${var.server_app_secret}"
      }
    }
  }

  network_profile {
    network_plugin     = "kubenet"
    service_cidr       = "${var.service_cidr}"
    dns_service_ip     = "${var.dns_service_ip}"
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku  = "standard" #Standard Loadbalancer (will soon be default!)
  }

  service_principal {
    client_id     = "${var.service_principal_id}"
    client_secret = "${var.service_principal_password}"
  }

  tags = {
    Environment   = "${var.environment}"
    Network       = "kubenet"
    RBAC          = "true"
    NetworkPolicy = "no"
  }
}
