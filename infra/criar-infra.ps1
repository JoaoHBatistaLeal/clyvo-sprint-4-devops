$ErrorActionPreference = "Stop"

$SUBSCRIPTION = "2026-2TDSPJ-JOAO-H-BATISTA-LEAL-RM564361"
$RG           = "rg-clyvo-sprint4"
$LOC          = "canadacentral"
$PLAN         = "plan-clyvo-sprint4"
$APP          = "clyvo-sprint4-rm564361"
$RUNTIME      = "dotnet:9"

Write-Host "1. Selecionando Subscription..."
az account set --subscription $SUBSCRIPTION

Write-Host "2. Criando Resource Group $RG em $LOC..."
az group create --name $RG --location $LOC

Write-Host "3. Criando App Service Plan $PLAN (SKU F1 - Windows)..."
az appservice plan create --name $PLAN --resource-group $RG --location $LOC --sku F1

Write-Host "4. Criando Azure Web App $APP com runtime $RUNTIME..."
az webapp create --name $APP --resource-group $RG --plan $PLAN --runtime $RUNTIME

Write-Host "5. Validando criacao do Web App..."
az webapp show --name $APP --resource-group $RG --query "{Name:name, State:state, DefaultHostName:defaultHostName}" --output table
