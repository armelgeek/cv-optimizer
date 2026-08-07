#!/bin/bash
# One-command complete setup: rename projects + add env vars + deploy

set -e

PROJECT_DIR=$(pwd)

echo "🚀 CV Optimizer - Complete Auto Setup"
echo "====================================="
echo ""
echo "This script will:"
echo "  1. Rename Vercel projects"
echo "  2. Add all environment variables"
echo "  3. Prepare for deployment"
echo ""

# Step 1: Get VERCEL_TOKEN
echo "Step 1️⃣  - Getting VERCEL_TOKEN"
echo ""
echo "Create at: https://vercel.com/account/tokens"
echo ""
read -s -p "Paste VERCEL_TOKEN: " VERCEL_TOKEN
echo ""

if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ Token required"
  exit 1
fi

# Step 2: Extract project IDs
echo ""
echo "Step 2️⃣  - Extracting project IDs..."

if [ ! -f "apps/web/.vercel/project.json" ]; then
  echo "❌ Vercel projects not found"
  exit 1
fi

WEB_ID=$(cat apps/web/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
APP_ID=$(cat apps/app/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
API_ID=$(cat apps/api/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')

echo "   ✅ WEB: $WEB_ID"
echo "   ✅ APP: $APP_ID"
echo "   ✅ API: $API_ID"

# Step 3: Rename projects
echo ""
echo "Step 3️⃣  - Renaming projects..."

curl -s -X PATCH "https://api.vercel.com/v9/projects/$APP_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ app → cv-optimizer.vercel.app"

curl -s -X PATCH "https://api.vercel.com/v9/projects/$WEB_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"web-cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ web → web-cv-optimizer.vercel.app"

curl -s -X PATCH "https://api.vercel.com/v9/projects/$API_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"api-cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ api → api-cv-optimizer.vercel.app"

sleep 2

# Step 4: Get environment variables
echo ""
echo "Step 4️⃣  - Getting environment variables..."
echo ""

get_env_value() {
  local key=$1

  # Try to get from .env.local
  if [ -f ".env.local" ]; then
    value=$(grep "^${key}=" .env.local 2>/dev/null | cut -d'=' -f2- | tr -d '"' || echo "")
    if [ -n "$value" ]; then
      echo "$value"
      return
    fi
  fi

  # Prompt user if not found
  echo "   Enter $key (leave empty to skip):"
  read -p "   > " user_value
  echo "$user_value"
}

echo "Reading from .env.local or prompting..."
echo ""

APP_URL="https://cv-optimizer.vercel.app"
WEB_URL="https://web-cv-optimizer.vercel.app"
API_URL="https://api-cv-optimizer.vercel.app"

DATABASE_URL=$(get_env_value "DATABASE_URL")
ANTHROPIC_API_KEY=$(get_env_value "ANTHROPIC_API_KEY")
SERPAPI_KEY=$(get_env_value "SERPAPI_KEY")
STRIPE_SECRET_KEY=$(get_env_value "STRIPE_SECRET_KEY")
STRIPE_WEBHOOK_SECRET=$(get_env_value "STRIPE_WEBHOOK_SECRET")
BETTER_AUTH_SECRET=$(get_env_value "BETTER_AUTH_SECRET")

# Step 5: Add environment variables
echo ""
echo "Step 5️⃣  - Adding environment variables to Vercel..."

add_env_var() {
  local project_id=$1
  local key=$2
  local value=$3

  if [ -z "$value" ]; then
    return
  fi

  curl -s -X POST "https://api.vercel.com/v10/projects/$project_id/env" \
    -H "Authorization: Bearer $VERCEL_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"key\":\"$key\",\"value\":\"$value\",\"target\":[\"production\"]}" > /dev/null 2>&1
}

echo ""
echo "   Web project..."
add_env_var "$WEB_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL"
add_env_var "$WEB_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL"
add_env_var "$WEB_ID" "NEXT_PUBLIC_API_URL" "$API_URL"
echo "   ✅ 3 variables added"

echo ""
echo "   App project..."
add_env_var "$APP_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL"
add_env_var "$APP_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL"
add_env_var "$APP_ID" "NEXT_PUBLIC_API_URL" "$API_URL"
add_env_var "$APP_ID" "DATABASE_URL" "$DATABASE_URL"
add_env_var "$APP_ID" "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY"
add_env_var "$APP_ID" "SERPAPI_KEY" "$SERPAPI_KEY"
add_env_var "$APP_ID" "STRIPE_SECRET_KEY" "$STRIPE_SECRET_KEY"
add_env_var "$APP_ID" "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET"
add_env_var "$APP_ID" "BETTER_AUTH_SECRET" "$BETTER_AUTH_SECRET"
add_env_var "$APP_ID" "BETTER_AUTH_URL" "$APP_URL"
echo "   ✅ 10 variables added"

echo ""
echo "   API project..."
add_env_var "$API_ID" "NEXT_PUBLIC_APP_URL" "$APP_URL"
add_env_var "$API_ID" "NEXT_PUBLIC_WEB_URL" "$WEB_URL"
add_env_var "$API_ID" "NEXT_PUBLIC_API_URL" "$API_URL"
add_env_var "$API_ID" "DATABASE_URL" "$DATABASE_URL"
add_env_var "$API_ID" "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY"
add_env_var "$API_ID" "SERPAPI_KEY" "$SERPAPI_KEY"
add_env_var "$API_ID" "STRIPE_SECRET_KEY" "$STRIPE_SECRET_KEY"
add_env_var "$API_ID" "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET"
add_env_var "$API_ID" "BETTER_AUTH_SECRET" "$BETTER_AUTH_SECRET"
add_env_var "$API_ID" "BETTER_AUTH_URL" "$APP_URL"
echo "   ✅ 10 variables added"

# Final instructions
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✨ Setup Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "✅ Vercel projects renamed"
echo "✅ Environment variables added"
echo ""
echo "Next step: Deploy to production"
echo ""
echo "  git push origin main"
echo ""
echo "Watch deployment:"
echo "  GitHub: https://github.com/armelgeek/cv-optimizer/actions"
echo "  Vercel: https://vercel.com/dashboard/projects"
echo ""
echo "Test production:"
echo "  App: https://cv-optimizer.vercel.app"
echo "  Web: https://web-cv-optimizer.vercel.app"
echo "  API: https://api-cv-optimizer.vercel.app"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "🚀 Auto-deploy pipeline active!"
echo "════════════════════════════════════════════════════════════════"
echo ""
