data "azurerm_resource_group" "rg" {
  name = "example-resource-group"
}

data "azurerm_virtual_network" "vn" {
  name                = "example-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.prefix}-vm-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vn.name
  address_prefixes     = [var.vm_subnet]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vn.name
  address_prefixes     = [var.aks_subnet]
}

resource "azurerm_public_ip" "vm_pub_ip" {
  name                = "${var.prefix}-vm-public-ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  domain_name_label   = "example-domain"
}

resource "azurerm_network_interface" "vm_ni" {
  name                = "${var.prefix}-vm-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm_nic_config"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_vm_ni
    public_ip_address_id          = azurerm_public_ip.vm_pub_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-vm-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule = [
    {
      name                        = "SSH"
      priority                    = 100
      access                      = "Allow"
      direction                   = "Inbound"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
    {
      name                        = "HTTP_OUT"
      priority                    = 110
      access                      = "Allow"
      direction                   = "Outbound"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "80"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
    {
      name                        = "HTTP_IN"
      priority                    = 120
      access                      = "Allow"
      direction                   = "Inbound"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "80"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
    {
      name                        = "APP_PORT"
      priority                    = 130
      access                      = "Allow"
      direction                   = "Inbound"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "8080"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
  ]
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.vm_ni.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Generate SSH key
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}-linux-vm"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  size                  = "Standard_B2s"
  admin_username        = var.username
  network_interface_ids = [azurerm_network_interface.vm_ni.id]

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.vm_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks-cluster"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "example-aks"

  default_node_pool {
    name           = "agentpool"
    node_count     = var.agent_count
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }
}

# Output private key (for test/dev only)
output "tls_private_key" {
  value     = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}
