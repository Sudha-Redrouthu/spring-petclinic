#!/bin/bash

# ===== USER CONFIGURATION =====
RESOURCE_GROUP="petclinic-rg"
ACR_NAME="sudhapetclinic01"
APP_PLAN="petclinic-plan"
WEBAPP_NAME="springpetclinic-webapp"
LOCATION="canadacentral"
IMAGE_NAME="spring-petclinic"
TAG="latest"

echo "💠 Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "💠 Creating Azure Container Registry (ACR)..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $LOCATION

echo "💠 Logging in to ACR..."
az acr login --name $ACR_NAME

echo "💠 Building Docker Image..."
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG .

echo "💠 Pushing Docker Image to ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

echo "💠 Creating Linux App Service Plan..."
az appservice plan create --name $APP_PLAN --resource-group $RESOURCE_GROUP --sku B1 --is-linux

echo "💠 Creating Azure Web App for Containers..."
az webapp create --resource-group $RESOURCE_GROUP \
  --plan $APP_PLAN \
  --name $WEBAPP_NAME \
  --deployment-container-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

echo "💠 Setting container image and registry on Web App..."
az webapp config container set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io

echo "💠 Setting WEBSITES_PORT=8080 (Spring Boot default)..."
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings WEBSITES_PORT=8080

echo "✅ Deployment complete!"
echo "🌐 Visit: https://$WEBAPP_NAME.azurewebsites.net"
