#!/bin/bash
# Add environment variables to Vercel projects via API

set -e

PROJECT_DIR=$(pwd)

echo "🔐 CV Optimizer - Add Environment Variables to Vercel"
echo "===================================================="
echo ""

# Get VERCEL_TOKEN
echo "Step 1️⃣  - Get VERCEL_TOKEN"
echo ""
echo "Create at: https://vercel.com/account/tokens"
echo ""
read -s -p "Paste VERCEL_TOKEN: " VERCEL_TOKEN
echo ""

if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ Token required"
  exit 1
fi

# Extract project IDs
echo ""
echo "Step 2️⃣  - Extracting project IDs..."

WEB_ID=$(cat apps/web/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
APP_ID=$(cat apps/app/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
API_ID=$(cat apps/api/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')

echo "   ✅ Found: WEB=$WEB_ID, APP=$APP_ID, API=$API_ID"

# Get environment variables from .env.local or user input
echo ""
echo "Step 3️⃣  - Getting environment variables..."
echo ""

get_env_value() {
  local key=$1
  local default=$2

  # Try to get from .env.local
  if [ -f ".env.local" ]; then
    value=$(grep "^${key}=" .env.local 2>/dev/null | cut -d'=' -f2- | tr -d '"' || echo "")
    if [ -n "$value" ]; then
      echo "$value"
      return
    fi
  fi

  # Prompt user if not found
  echo "   Enter $key (or press Enter to skip):"
  read -p "   > " user_value
  echo "$user_value"
}

echo "Reading from .env.local or prompting..."
echo ""

APP_URL="https://cv-optimizer.vercel.app"
WEB_URL="https://web-cv-optimizer.vercel.app"
API_URL="https://api-cv-optimizer.vercel.app"

DATABASE_URL=$(get_env_value "DATABASE_URL" "")
ANTHROPIC_API_KEY=$(get_env_value "ANTHROPIC_API_KEY" "")
SERPAPI_KEY=$(get_env_value "SERPAPI_KEY" "")
STRIPE_SECRET_KEY=$(get_env_value "STRIPE_SECRET_KEY" "")
STRIPE_WEBHOOK_SECRET=$(get_env_value "STRIPE_WEBHOOK_SECRET" "")
BETTER_AUTH_SECRET=$(get_env_value "BETTER_AUTH_SECRET" "dev-secret-key-min32chars")

# Function to add env var via API
add_env_var() {
  local project_id=$1
  local key=$2
  local value=$3
  local project_name=$4

  if [ -z "$value" ]; then
    echo "   ⊘ $key (skipped - empty)"
    return
  fi

  curl -s -X POST "https://api.vercel.com/v10/projects/$project_id/env" \
    -H "Authorization: Bearer $VERCEL_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"key\":\"$key\",\"value\":\"$value\",\"target\":[\"production\"]}" > /dev/null 2>&1

  echo "   ✅ $key"
}

# Add to Web project
echo ""
echo "Adding to Web project ($WEB_ID)..."
add_env_var "$WEB_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL" "web"
add_env_var "$WEB_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL" "web"
add_env_var "$WEB_ID" "NEXT_PUBLIC_API_URL" "$API_URL" "web"

# Add to App project
echo ""
echo "Adding to App project ($APP_ID)..."
add_env_var "$APP_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL" "app"
add_env_var "$APP_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL" "app"
add_env_var "$APP_ID" "NEXT_PUBLIC_API_URL" "$API_URL" "app"
add_env_var "$APP_ID" "DATABASE_URL" "$DATABASE_URL" "app"
add_env_var "$APP_ID" "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY" "app"
add_env_var "$APP_ID" "SERPAPI_KEY" "$SERPAPI_KEY" "app"
add_env_var "$APP_ID" "STRIPE_SECRET_KEY" "$STRIPE_SECRET_KEY" "app"
add_env_var "$APP_ID" "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET" "app"
add_env_var "$APP_ID" "BETTER_AUTH_SECRET" "$BETTER_AUTH_SECRET" "app"
add_env_var "$APP_ID" "BETTER_AUTH_URL" "$APP_URL" "app"

# Add to API project
echo ""
echo "Adding to API project ($API_ID)..."
add_env_var "$API_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL" "api"
add_env_var "$API_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL" "api"
add_env_var "$API_ID" "NEXT_PUBLIC_API_URL" "$API_URL" "api"
add_env_var "$API_ID" "DATABASE_URL" "$DATABASE_URL" "api"
add_env_var "$API_ID" "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY" "api"
add_env_var "$API_ID" "SERPAPI_KEY" "$SERPAPI_KEY" "api"
add_env_var "$API_ID" "STRIPE_SECRET_KEY" "$STRIPE_SECRET_KEY" "api"
add_env_var "$API_ID" "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET" "api"
add_env_var "$API_ID" "BETTER_AUTH_SECRET" "$BETTER_AUTH_SECRET" "api"
add_env_var "$API_ID" "BETTER_AUTH_URL" "$APP_URL" "api"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ Environment variables added to Vercel!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Next step: Deploy!"
echo ""
echo "  git push origin main"
echo ""
echo "Watch at: https://github.com/armelgeek/cv-optimizer/actions"
echo ""
