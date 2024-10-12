data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "default_keyvault" {
  name                        = "kv-${var.client_name}-${var.resource_group.location}"
  location                    = var.resource_group.location
  resource_group_name         = var.resource_group.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false   
  sku_name                    = "standard"

  lifecycle {
    prevent_destroy = false
  }
}

# Separating Access Policies into their own resources

resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = azurerm_key_vault.default_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]
  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "contributor_policy" {
  key_vault_id = azurerm_key_vault.default_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_group.grp_contributors.id

  key_permissions = [
    "Create", "Decrypt", "Encrypt", "Get", "List", "Update", "Verify", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]
  secret_permissions = [
    "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"
  ]
  storage_permissions = [
    "Backup", "Get", "GetSAS", "List", "ListSAS", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "reader_policy" {
  key_vault_id = azurerm_key_vault.default_keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_group.grp_readers.id

  key_permissions = [
    "Get", "List", "GetRotationPolicy", "WrapKey", "UnwrapKey"
  ]
  secret_permissions = [
    "Get", "List",
  ]
  storage_permissions = [
    "Get", "GetSAS", "List", "ListSAS"
  ]
}

resource "azuread_group" "grp_readers" {
  display_name     = "readers-kv-grp-${var.client_name}-${var.resource_group.location}"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
  members          = var.readers
}

resource "azuread_group" "grp_contributors" {
  display_name     = "contr-kv-grp-${var.client_name}-${var.resource_group.location}"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
  members          = var.contributors
}