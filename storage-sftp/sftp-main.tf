data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}


resource "azurerm_storage_account" "sftppub" {
  for_each = var.SFTP
  name                     = "stosftp${var.client_name}${each.key}${var.random_s4}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  sftp_enabled             = true
#  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      allowed_origins    = ["*"]
      exposed_headers    = ["Date"]
      max_age_in_seconds = 3600
    }
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }
  # lifecycle {
  #   prevent_destroy = true
  # }

}

resource "azurerm_storage_encryption_scope" "sftpencryption" {
  for_each = azurerm_storage_account.sftppub
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.sftppub[each.key].id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_container" "sftpcontainer" {
  for_each = {
    for idx, container in local.containers : idx => container
  }
  name                  = lower(each.value.cont_name)
  storage_account_name  = azurerm_storage_account.sftppub[each.value.storage_name].name
  container_access_type = "blob"
}

resource "azurerm_key_vault_secret" "key_sftp_primary_conn" {
  for_each = azurerm_storage_account.sftppub
  name         = "accnt-sftp-conn-${each.key}"    
  key_vault_id = var.keyvault_id
  value        = azurerm_storage_account.sftppub[each.key].primary_connection_string
}

resource "azurerm_storage_account_local_user" "sftp_users" {
  for_each           = {for key, user in local.sftpusers: key => user}
  name               = lower(each.value.user_name)
  storage_account_id = azurerm_storage_account.sftppub[each.value.storage_name].id
  ssh_key_enabled    = each.value.key_enabled

  # The first container in the `permissions_scopes` list will always be the default home directory
  home_directory = coalesce(each.value.home_directory, each.value.permissions_scopes[0].target_container)

  dynamic "permission_scope" {
    for_each = each.value.permissions_scopes
    content {
      service       = "blob"
      resource_name = permission_scope.value.target_container
      permissions {
        create = contains(permission_scope.value.permissions, "All") || contains(permission_scope.value.permissions, "Create")
        delete = contains(permission_scope.value.permissions, "All") || contains(permission_scope.value.permissions, "Delete")
        list   = contains(permission_scope.value.permissions, "All") || contains(permission_scope.value.permissions, "List")
        read   = contains(permission_scope.value.permissions, "All") || contains(permission_scope.value.permissions, "Read")
        write  = contains(permission_scope.value.permissions, "All") || contains(permission_scope.value.permissions, "Write")
      }
    }
  }

  dynamic "ssh_authorized_key" {
    for_each = each.value.key_enabled ? each.value.keys : []
    content {
      key         = ssh_authorized_key.value.key
      description = ssh_authorized_key.value.description
    }
  }

}


