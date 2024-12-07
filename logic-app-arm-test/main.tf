locals {
  api_connection_name = "api-automation-${var.environment}-${var.location_short}"
}

resource "azurerm_resource_group" "automation" {
  name     = "rg-automation-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "identity" {
  location            = var.location
  name                = "id-automation-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.automation.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "identity_rbac" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_resource_group_template_deployment" "api_connection" {
  name                = "arm-api-automation-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.automation.name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/api_connection.json")

  parameters_content = jsonencode({
    "api_connection_name" = {
      value = local.api_connection_name
    }
  })

  tags = var.tags
}

resource "azurerm_logic_app_workflow" "automation" {
  depends_on = [azurerm_resource_group_template_deployment.api_connection]

  name                = "logic-automation-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.automation.name
  enabled             = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  parameters = {
    "$connections" = jsonencode(
      {
        arm = {
          id             = jsondecode(azurerm_resource_group_template_deployment.api_connection.output_content).api_id.value
          connectionId   = jsondecode(azurerm_resource_group_template_deployment.api_connection.output_content).id.value
          connectionName = local.api_connection_name
          connectionProperties = {
            authentication = {
              identity = azurerm_user_assigned_identity.identity.id
              type     = "ManagedServiceIdentity"
            }
          }
        }
      }
    )
  }
  workflow_parameters = {
    "$connections" = jsonencode(
      {
        defaultValue = {}
        type         = "Object"
      }
    )
  }
}

resource "azurerm_resource_group_template_deployment" "workflow" {
  depends_on = [azurerm_logic_app_workflow.automation]

  name                = "arm-workflow-automation-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.automation.name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/logic_app.json")

  parameters_content = jsonencode({
    "logic_app_name" = {
      value = azurerm_logic_app_workflow.automation.name
    },
    "location" = {
      value = var.location
    },
    "time_zone" = {
      value = var.time_zone
    },
    "recurrence_interval" = {
      value = "1"
    },
    "recurrence_frequency" = {
      value = "Hour"
    },
    "subscription_id" = {
      value = var.subscription_id
    },
    "connection_api_id" = {
      value = jsondecode(azurerm_resource_group_template_deployment.api_connection.output_content).api_id.value
    },
    "connection_id" = {
      value = jsondecode(azurerm_resource_group_template_deployment.api_connection.output_content).id.value
    },
    "connection_name" = {
      value = local.api_connection_name
    }
    "identity_id" = {
      value = azurerm_user_assigned_identity.identity.id
    },
  })

  tags = var.tags
}
