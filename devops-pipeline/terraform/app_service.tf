resource "azurerm_app_service" "main" {
  name                = "cx-affinity-kiosk-app-${var.environment_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  https_only          = true

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL          = "https://${data.azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = data.azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = data.azurerm_container_registry.main.admin_password
  }

  site_config {
    always_on          = true
    websockets_enabled = true
    http2_enabled      = true
    linux_fx_version   = "DOCKER|${data.azurerm_container_registry.main.login_server}/${var.container_image_name}"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [app_settings, site_config]
  }
}

resource "azurerm_app_service_custom_hostname_binding" "main" {
  hostname            = local.custom_domain
  app_service_name    = azurerm_app_service.main.name
  resource_group_name = azurerm_resource_group.main.name

  # Ignore ssl_state and thumbprint as they are managed using
  # azurerm_app_service_certificate_binding.example
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_app_service_managed_certificate" "main" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.main.id
}

resource "azurerm_app_service_certificate_binding" "main" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.main.id
  certificate_id      = azurerm_app_service_managed_certificate.main.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_slot" "main" {
  name                = "staging"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  https_only          = true
  app_service_name    = azurerm_app_service.main.name

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL          = "https://${data.azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = data.azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = data.azurerm_container_registry.main.admin_password
  }

  site_config {
    always_on          = true
    websockets_enabled = true
    http2_enabled      = true
    linux_fx_version   = "DOCKER|${data.azurerm_container_registry.main.login_server}/${var.container_image_name}"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [app_settings, site_config]
  }
}
