
resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroup_name
  location = var.location
}

resource "azurerm_storage_account" "asa" {
  name     = var.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "asc" {
  name     = var.storage_container_name
  storage_account_name = azurerm_storage_account.asa.name
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.loadBalancer_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  

  frontend_ip_configuration {
    name                 = var.loadBalancer_frontend_ip_name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_lb_backend_address_pool" "albap" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = var.loadBalancer_backend_address_pool_name
}



resource "azurerm_lb_rule" "alr" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.albap.id
  frontend_ip_configuration_name = var.loadBalancer_frontend_ip_name
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtualnetwork_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_virtual_machine_scale_set" "example" {
  name                = var.virtual_machine_scale_set_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  upgrade_policy_mode = "Manual"
  sku {
   name     = "Standard_DS1_v2"
   tier     = "Standard"
   capacity = var.capacity
 }
 os_profile {
  computer_name_prefix = var.computer_name_prefix
  admin_password      = var.admin_password
  admin_username      = var.admin_username
}
  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_profile_os_disk {
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
  }

  network_profile {
    name    = var.network_profile_name
    primary = true

    ip_configuration {
      name      = var.network_ip_configuration_name
      primary   = true
      subnet_id = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.albap.id]
    }
  }
}


#------------------------------------------------------###################
# BASTION
#------------------------------------------------------###################
resource "azurerm_public_ip" "bastion" {
  name                = var.bation_public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create bastion subnet

resource "azurerm_subnet" "bastion" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/27"]
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bation_host_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = var.bation_ip_configuration_name
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

