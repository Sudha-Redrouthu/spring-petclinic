#!/bin/bash

# ===== CONFIGURATION =====
RESOURCE_GROUP="Project_1"
ACR_NAME="sudhapetclinic01"
APP_PLAN="petclinic-plan"
WEBAPP_NAME="springpetclinic-webapp"

echo "⚠️ This will delete the ACR, Web App, and App Service Plan ONLY."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" == "yes" ]]; then
  echo "🗑️ Deleting Azure Web App..."
  az webapp delete --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

  echo "🗑️ Deleting App Service Plan..."
  az appservice plan delete --name $APP_PLAN --resource-group $RESOURCE_GROUP --yes

  echo "🗑️ Deleting Azure Container Registry (ACR)..."
  az acr delete --name $ACR_NAME --resource-group $RESOURCE_GROUP --yes

  echo "✅ Cleanup complete. Your resource group '$RESOURCE_GROUP' still exists."
else
  echo "❌ Canceled. No resources were deleted."
fi
