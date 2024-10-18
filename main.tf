data "azurerm_client_config" "current" {}

data "azuread_group" "sqlserveradmin" {
  display_name = "iTrax - SQL Admins"
}

locals {
  readers = [
  ]
  contributors = [
    data.azuread_group.sqlserveradmin.object_id
  ]
}

resource "azurerm_resource_group" "prod_rg" {
  name     = "iTraxBlazerProd_RG"
  location = "East US 2"
}

# Azure SQL Server
resource "azurerm_mssql_server" "azuresqlserver" {
  name                = "${var.client_name}-itrax-sqlserver-prod"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = azurerm_resource_group.prod_rg.location
  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    login_username              = data.azuread_group.sqlserveradmin.display_name
    object_id                   = data.azuread_group.sqlserveradmin.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true # Enforce Azure Entra-only authentication
  }
}

# SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name         = "iTraxBlazer_db"
  server_id    = azurerm_mssql_server.azuresqlserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS" # Specify the collation
  license_type = "LicenseIncluded"              # License configuration
  max_size_gb  = 400                            # Specify database size
  sku_name     = "GP_Gen5_2"                    # Database SKU (e.g., S0, S1, etc.)
  enclave_type = "VBS"                          # Optional enclave setting

    # Short-term backup retention for PITR
  short_term_retention_policy {
    retention_days = 7 # Customize the number of days (e.g., 7, 14, 35 days)
  }
    # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}


# Service Plan
resource "azurerm_service_plan" "service_plan" {
  name                = "${var.client_name}-webserver-plan"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  os_type             = "Windows"
  sku_name            = "P0v3"
}

# Windows Web App
resource "azurerm_windows_web_app" "web_app" {
  name                = "${var.client_name}-service"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id

  site_config {
    application_stack {
      current_stack  = "dotnetcore"
      dotnet_version = "v8.0"
    }
    use_32_bit_worker = false
    http2_enabled = true
    websockets_enabled = true
  }

  #   lifecycle {
  #   ignore_changes = [site_config[0].application_stack]
  # }
}

resource "random_string" "random_s4" {
  length  = 4
  special = false
  upper   = false
}

module "keyvault" {
  source         = "./keyvault"
  resource_group = azurerm_resource_group.prod_rg
  location       = azurerm_resource_group.prod_rg.location
  client_name    = var.client_name
  readers        = local.readers
  contributors   = local.contributors
  contributor     = data.azuread_group.sqlserveradmin.object_id
}

module "storage-sftp" {
  source         = "./storage-sftp"
  SFTP           = var.SFTP
  client_name    = var.client_name
  resource_group = azurerm_resource_group.prod_rg
  keyvault_id    = module.keyvault.keyvault_id
  random_s4      = random_string.random_s4.result
}