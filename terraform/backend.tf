terraform {
  backend "azurerm" {
    resource_group_name  = "example-rg"
    storage_account_name = "examplestorageacct"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
