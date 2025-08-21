# Leemos el ACR y su admin (debe estar habilitado)
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}