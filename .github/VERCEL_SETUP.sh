#!/bin/bash
# Add Vercel secrets to GitHub for CI/CD deployment

set -e

echo "🔐 Vercel GitHub Secrets Setup"
echo "=============================="
echo ""
echo "This script adds Vercel credentials to GitHub Secrets."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) not installed"
  echo "   Install from: https://cli.github.com"
  exit 1
fi

# Get credentials
ORG_ID="team_wwl8joXyLSioTgwXOA0oZq6x"
PROJECT_ID_WEB="prj_RTXjwo8xOJlIPaeJV2Ec5qEi1wtA"
PROJECT_ID_APP="prj_HorISnu0MGK0BFTLDXO7Qtzf6WVY"
PROJECT_ID_API="prj_ErcLqBT2XO0mMtzrlXx94apifZG8"

# Prompt for token
echo "1️⃣  Get your VERCEL_TOKEN:"
echo "   https://vercel.com/account/tokens"
echo ""
read -p "Paste VERCEL_TOKEN: " VERCEL_TOKEN

if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ Token cannot be empty"
  exit 1
fi

# Add secrets
echo ""
echo "2️⃣  Adding secrets to GitHub..."
echo ""

gh secret set VERCEL_TOKEN --body "$VERCEL_TOKEN" 2>&1 | tail -1
gh secret set VERCEL_ORG_ID --body "$ORG_ID" 2>&1 | tail -1
gh secret set VERCEL_PROJECT_ID_WEB --body "$PROJECT_ID_WEB" 2>&1 | tail -1
gh secret set VERCEL_PROJECT_ID_APP --body "$PROJECT_ID_APP" 2>&1 | tail -1
gh secret set VERCEL_PROJECT_ID_API --body "$PROJECT_ID_API" 2>&1 | tail -1

echo ""
echo "✅ Secrets added!"
echo ""
echo "3️⃣  Add environment variables in Vercel console:"
echo ""
echo "For each project (web, app, api) at vercel.com:"
echo ""
echo "Web project:"
echo "  NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app"
echo "  NEXT_PUBLIC_WEB_URL=https://web-armelgeeks-projects.vercel.app"
echo "  NEXT_PUBLIC_API_URL=https://api-armelgeeks-projects.vercel.app"
echo ""
echo "App project:"
echo "  DATABASE_URL=postgresql://..."
echo "  ANTHROPIC_API_KEY=sk-ant-..."
echo "  SERPAPI_KEY=..."
echo "  STRIPE_SECRET_KEY=sk_live_..."
echo "  STRIPE_WEBHOOK_SECRET=whsec_..."
echo "  BETTER_AUTH_SECRET=min-32-chars"
echo "  NEXT_PUBLIC_* (same as Web)"
echo ""
echo "API project:"
echo "  (same as App project, without NEXT_PUBLIC_*)"
echo ""
echo "4️⃣  Done! Push to main to trigger deployment:"
echo ""
echo "  git push origin main"
echo ""
echo "✨ Auto-deploy enabled!"
