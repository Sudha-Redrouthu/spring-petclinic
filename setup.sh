#!/bin/bash

# ===== CONFIGURATION =====
RESOURCE_GROUP="Project_1"
ACR_NAME="sudhapetclinic01"
APP_PLAN="petclinic-plan"
WEBAPP_NAME="springpetclinic-webapp"
LOCATION="canadacentral"
IMAGE_NAME="spring-petclinic"
TAG="$(Build.BuildId)"  # Or use 'latest' if that's your tag in release

# 📦 Recreate ACR (optional if already recreated by pipeline)
echo "📦 Creating ACR..."
az acr create --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --location $LOCATION

# 🛠️ Create App Service Plan
echo "🛠️ Creating App Service Plan (B1)..."
az appservice plan create --name $APP_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux \
  --location $LOCATION

# 🌐 Create Web App for Containers
echo "🌐 Creating Web App..."
az webapp create --resource-group $RESOURCE_GROUP \
  --plan $APP_PLAN \
  --name $WEBAPP_NAME \
  --deployment-container-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

# 🔗 Link Web App to ACR
echo "🔗 Configuring Web App with ACR image..."
az webapp config container set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io

# ⚙️ Set port (Spring Boot default)
echo "⚙️ Setting WEBSITES_PORT=8080..."
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings WEBSITES_PORT=8080

echo "✅ Setup complete!"
echo "🌐 Your app: https://$WEBAPP_NAME.azurewebsites.net"
