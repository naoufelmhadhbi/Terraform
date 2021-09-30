variable resourcegroup_name {
  type = string
  description = "the name for my resource group"
}
variable storage_account_name {
  type = string
  description = "the name for my storage account"
}

variable storage_container_name {
  type = string
  description = "the name for my storage container"
}

variable location {
  type = string
  description = "the location for my Azure resources"
}

variable virtualnetwork_name {
  type = string
  description = "the name for my virtual network"
}

variable public_ip_name {
  type = string
  description = "my public ip address name"
}

variable loadBalancer_name {
  type = string
  description = "the name of my load balancer"
}

variable loadBalancer_frontend_ip_name {
  type = string
  description = "the name of my load balancer's frontend ip address"
}

variable loadBalancer_backend_address_pool_name {
  type = string
  description = "the name of my load balancer's backend address pool"
}

variable subnet_name {
  type = string
  description = "the name of my subnet"
}

variable bastion_subnet_name {
  type = string
  description = "the name of my bastion subnet"
}

variable virtual_machine_scale_set_name {
  type = string
  description = "the name of my virtual machine scale set"
}

variable capacity {
  type = number
  description = "this is the number of virtual machines in my scale set"
}

variable computer_name_prefix {
  type = string
  description = "this is my computer name prefix"
}

variable admin_password {
  type = string
  description = "this is my admin password"
}

variable admin_username {
  type = string
  description = "this is my admin username"
}

variable network_profile_name {
  type = string
  description = "this is my network profile name"
}

variable network_ip_configuration_name {
  type = string
  description = "this is my network ip configuration name"
}

variable bation_public_ip_name {
  type = string
  description = "my bation public ip address name"
}

variable bation_host_name {
  type = string
  description = "my bation host name"
}

variable bation_ip_configuration_name {
  type = string
  description = "this is my bation ip configuration name"
}
