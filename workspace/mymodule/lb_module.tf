resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroup_name
  location = var.location
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

# Create bastion
resource "azurerm_subnet" "bastion" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/27"]
}

/*
# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}*/

/*
# Create network interface
resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "myNIC${count.index}"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    # public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
*/
/*
resource "azurerm_managed_disk" "amd" {
  count                = 3
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}*/
/*
# Create azurerm_availability_set
resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}
*/
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
   name              = ""
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
/*
resource "azurerm_virtual_machine_scale_set_extension" "example" {
  name                         = "example"
  virtual_machine_scale_set_id = azurerm_virtual_machine_scale_set.example.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.8"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools ; remove-item  C:\inetpub\wwwroot\iisstart.htm"
  })*/

       //; powershell -ExecutionPolicy Unrestricted remove-item  C:\inetpub\wwwroot\iisstart.htm
    //; powershell -ExecutionPolicy Unrestricted Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value $("Hello World from " + $env:computername)"
  //SETTINGS 
  /*settings = <<SETTINGS
    {
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted remove-item  C:\inetpub\wwwroot\iisstart.htm"
  }
  SETTINGS
    settings = <<SETTINGS
    {
    "commandToExecute" = "powershell -ExecutionPolicy Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value $("Hello World from " + $env:computername)"
  }
  SETTINGS*/
//}

/*variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
}*/

/*
# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  count                 = 3
  name                  = "myTFVM${count.index}"
  location              = "westus2"
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  size               = "Standard_DS1_v2"
  admin_username        = "myTFVM${count.index}"
  admin_password        = "myTFVM${count.index}myTFVM${count.index}"

  os_disk {
    name              = "myOsDisk${count.index}"
    caching           = "ReadWrite"
    //create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

 }
 */
/*
  os_profile {
    computer_name  = "myTFVM"
    //admin_username = var.admin_username
    admin_username = "myTFVM_Username"
    admin_password = "myTFVM_Password"
  }

  os_profile_windows_config {
     enable_automatic_upgrades = false
   }
}*/

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

