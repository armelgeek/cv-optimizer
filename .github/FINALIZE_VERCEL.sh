#!/bin/bash
# Finalize Vercel setup: rename projects + guide for env vars

set -e

PROJECT_DIR=$(pwd)

echo "🚀 CV Optimizer - Finalize Vercel Setup"
echo "========================================"
echo ""

# Get VERCEL_TOKEN
echo "Step 1️⃣  - Get VERCEL_TOKEN for API access"
echo ""
echo "Create at: https://vercel.com/account/tokens"
echo "Scope: Full Access"
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

# Rename projects
echo ""
echo "Step 3️⃣  - Renaming projects for clean URLs..."
echo ""

echo "   Renaming app → cv-optimizer..."
curl -s -X PATCH "https://api.vercel.com/v9/projects/$APP_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ App renamed → cv-optimizer.vercel.app"

echo "   Renaming web → web-cv-optimizer..."
curl -s -X PATCH "https://api.vercel.com/v9/projects/$WEB_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"web-cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ Web renamed → web-cv-optimizer.vercel.app"

echo "   Renaming api → api-cv-optimizer..."
curl -s -X PATCH "https://api.vercel.com/v9/projects/$API_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"api-cv-optimizer"}' > /dev/null 2>&1
echo "   ✅ API renamed → api-cv-optimizer.vercel.app"

sleep 3

# Show final instructions
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Step 4️⃣  - Add Environment Variables (Manual - 5 min)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Go to: https://vercel.com/dashboard/projects"
echo ""
echo "For EACH project, click Settings → Environment Variables → Add:"
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ All 3 projects need:                                        │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app        │"
echo "│ NEXT_PUBLIC_WEB_URL=https://web-cv-optimizer.vercel.app    │"
echo "│ NEXT_PUBLIC_API_URL=https://api-cv-optimizer.vercel.app    │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ App & API projects ALSO need (get from .env.local):         │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ DATABASE_URL                                                │"
echo "│ ANTHROPIC_API_KEY                                           │"
echo "│ SERPAPI_KEY                                                 │"
echo "│ STRIPE_SECRET_KEY                                           │"
echo "│ STRIPE_WEBHOOK_SECRET                                       │"
echo "│ BETTER_AUTH_SECRET                                          │"
echo "│ BETTER_AUTH_URL=https://cv-optimizer.vercel.app            │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "Current env vars in .env.local:"
grep -E "^[A-Z_]+" .env.local 2>/dev/null | head -10 || echo "(none found)"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Step 5️⃣  - Deploy & Watch"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "When env vars are added to Vercel, trigger deployment:"
echo ""
echo "  git push origin main"
echo ""
echo "Watch at:"
echo "  https://github.com/armelgeek/cv-optimizer/actions"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✨ Setup Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
