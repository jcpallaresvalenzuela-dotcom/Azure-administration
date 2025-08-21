# Variables
SUBSCRIPTION_ID="<tu-subscription-id>"
RESOURCE_GROUP="<tu-resource-group>"
ACR_NAME="<tu-acr-name>"

# Seleccionar suscripción
az account set -s "$SUBSCRIPTION_ID"

# Obtener el resource ID del ACR
ACR_ID=$(az acr show -g "$RESOURCE_GROUP" -n "$ACR_NAME" --query id -o tsv)

# Crear Service Principal con permisos mínimos sobre el ACR (AcrDelete) y obtener JSON --sdk-auth
# Guarda el JSON en sp.json (lo pegarás tal cual en el secret SERVICE_PRINCIPAL del environment dev)
az ad sp create-for-rbac \
  --name "sp-acr-delete-$ACR_NAME" \
  --role "AcrDelete" \
  --scopes "$ACR_ID" \
  --sdk-auth > sp.json

# (Opcional) Si el rol AcrDelete no está disponible en tu tenant, usa AcrPush como alternativa:
# az ad sp create-for-rbac --name "sp-acr-delete-$ACR_NAME" --role "AcrPush" --scopes "$ACR_ID" --sdk-auth > sp.json

# Verifica que el SP tenga el rol asignado correctamente
az role assignment list --assignee "$(jq -r .clientId sp.json)" --scope "$ACR_ID" -o table