# storage account should be unique in Azure
resource "azurerm_storage_account" "data_backup_storage_acount" {
  name                     = "databack${var.environment}${random_id.storage_account_suffix.hex}"
  resource_group_name      = azurerm_resource_group.data_backup.name
  location                 = azurerm_resource_group.data_backup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }

  # primary_access_key
}

resource "azurerm_storage_container" "dbbackup_storage_container" {
  name                  = "stackgresdbbackup"
  storage_account_name  = azurerm_storage_account.data_backup_storage_acount.name
  container_access_type = "private"
}

