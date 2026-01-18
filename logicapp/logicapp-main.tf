
terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.47.0"
    }
  }
}

# ---------- App Service Plan ----------
resource "azurerm_service_plan" "logicapp_plan" {
  name                = "${var.client_name}-logicapp-plan"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  os_type   = "Windows"
  sku_name  = "WS1"
  worker_count = 1
}

# ---------- Storage for Logic App content ----------
resource "azurerm_storage_account" "logicapp_sa" {
  name                     = "st${replace(lower(var.resource_group.location), " ", "")}hahlogicapp01" # must be globally unique; adjust
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # recommended for app content
  #enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

resource "azurerm_storage_share" "logicapp_content" {
  name                 = "${var.client_name}-logicapp-content"
  storage_account_id = azurerm_storage_account.logicapp_sa.id
  quota                = 100
}

# ---------- Logic App Standard (the "site") ----------
resource "azurerm_logic_app_standard" "hahlogicapp" {
  name                = "${var.client_name}-logicapp"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  app_service_plan_id = azurerm_service_plan.logicapp_plan.id

  storage_account_name       = azurerm_storage_account.logicapp_sa.name
  storage_account_access_key = azurerm_storage_account.logicapp_sa.primary_access_key
  storage_account_share_name = azurerm_storage_share.logicapp_content.name

  https_only = true
  enabled    = true

  identity {
    type = "SystemAssigned"
  }

  # App settings that your connections.json references
  app_settings = {
    # SMTP service provider settings referenced by @appsetting(...)
    "Smtp_12_enableSSL"      = "true"
    "Smtp_12_port"           = "587"
    "Smtp_12_serverAddress"  = "smtp.mailgun.org"
    "Smtp_12_username"       = "REDACT_ME"
    "Smtp_12_password"       = "REDACT_ME"
    "AzureFunctionsJobHost__extensionBundle__version" = "1.117.31"

    # Good practice: ensure the runtime has a package deployment mode you like.
    # "WEBSITE_RUN_FROM_PACKAGE" = "1"   # (optional; if you deploy zip as package)
  }

  site_config {
    ftps_state               = "FtpsOnly"
    min_tls_version          = "1.2"
    scm_min_tls_version      = "1.2"
    runtime_scale_monitoring_enabled = true
  }
}

# ---------- Managed API connection: sqldw ----------
# Your connections.json references:
#  managedApis/sqldw and /connections/sqldw with MSI auth.

data "azurerm_managed_api" "sqldw" {
  name     = "sqldw"
  location = var.resource_group.location
}

resource "azurerm_api_connection" "sqldw" {
  name                = "sqldw-hahlogicapp2"
  resource_group_name = var.resource_group.name
  managed_api_id      = data.azurerm_managed_api.sqldw.id

  # MSI authentication for the connector (matches connections.json)
  parameter_values = {
    "authenticationType" = "ManagedServiceIdentity"
  }
}

# If you want the Logic App identity to be able to USE the API connection,
# you typically need to grant it permissions to the API connection resource.
# Many setups work without explicit RBAC here, but if you hit auth issues,
# add a role assignment like this:
resource "azurerm_role_assignment" "logicapp_can_read_api_connection" {
  scope                = azurerm_api_connection.sqldw.id
  role_definition_name = "Reader"
  principal_id         = azurerm_logic_app_standard.hahlogicapp.identity[0].principal_id
}
