# Prefix for naming resources
variable "prefix" {
  default = "tf-exampleapp"
}

# Subnet definitions (private IP ranges)
variable "vm_subnet" {
  default = "10.1.0.0/24"
}

variable "aks_subnet" {
  default = "10.1.1.0/24"
}

# Network configuration for AKS or similar cluster setup
variable "service_cidr" {
  default = "10.250.0.0/16"
}

variable "dns_service_ip" {
  default = "10.250.0.10"
}

variable "docker_bridge_cidr" {
  default = "172.18.0.1/16"
}

# Private static IP address for a VM
variable "private_ip_vm_ni" {
  default = "10.1.0.100"
}

# SSH username for provisioning
variable "username" {
  default   = "exampleuser"
  sensitive = true
}

# Path to public SSH key
variable "public_key_path" {
  default   = "~/.ssh/exampleuser.pub"
  sensitive = true
}

# Number of agents/nodes to deploy
variable "agent_count" {
  default = 2
}
