#!/bin/bash
# ===========================================
# Azure Static Website Verification Script
# ===========================================
# This script checks and enables your static website
# on Azure Storage Account created via the Portal.
# ===========================================

set -euo pipefail

# Configuration
RG="emem-rg"
STORAGE="ememstatic541"
LOCATION="northeurope"

echo "--------------------------------------------"
echo "🔹 Resource Group: $RG"
echo "🔹 Storage Account: $STORAGE"
echo "🔹 Location: $LOCATION"
echo "--------------------------------------------"

# Checking available subscriptions
echo "Checking available subscriptions..."
az account list --output table

read -p "Enter your subscription name (as shown above): " SUB_NAME
az account set --subscription "$SUB_NAME"
echo "Using subscription: $SUB_NAME"

# Verify resource group
echo "Checking if resource group '$RG' exists..."
az group show --name "$RG" --output table || {
  echo "Resource group '$RG' not found. Please verify in the Portal."
  exit 1
}

# Step 4 — Verify storage account
echo "Checking if storage account '$STORAGE' exists..."
az storage account show -n "$STORAGE" -g "$RG" --output table || {
  echo "❌ Storage account '$STORAGE' not found in resource group '$RG'."
  exit 1
}

# Step 5 — Ensure static website feature is enabled
echo "🌐 Ensuring static website hosting is enabled..."
az storage blob service-properties update \
  --account-name "$STORAGE" \
  --static-website true \
  --index-document index.html \
  --404-document error.html

# Step 6 — Retrieve and display static website endpoint
WEB_URL=$(az storage account show -n "$STORAGE" -g "$RG" --query "primaryEndpoints.web" -o tsv)

echo "--------------------------------------------"
echo "🚀 Static website is active!"
echo "🌍 Access it here: $WEB_URL"
echo "--------------------------------------------"

# Step 7 — (Optional) Show configuration summary
echo "Resource Summary:"
az storage blob service-properties show --account-name "$STORAGE" --query "staticWebsite"
