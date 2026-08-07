#!/bin/bash
# Automated Vercel + GitHub setup for CV Optimizer

set -e

echo "🚀 CV Optimizer - Auto Setup Vercel + GitHub"
echo "=============================================="
echo ""

# Check dependencies
check_tools() {
  local missing=()

  if ! command -v vercel &> /dev/null; then
    missing+=("vercel CLI")
  fi
  if ! command -v gh &> /dev/null; then
    missing+=("GitHub CLI (gh)")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    echo "❌ Missing tools:"
    for tool in "${missing[@]}"; do
      echo "  - $tool"
    done
    echo ""
    echo "Install:"
    echo "  Vercel: npm i -g vercel"
    echo "  GitHub: https://cli.github.com"
    exit 1
  fi
}

# Extract Vercel project info
extract_vercel_info() {
  echo "📋 Extracting Vercel project information..."

  if [ ! -f "apps/web/.vercel/project.json" ]; then
    echo "❌ Vercel projects not found. Run first:"
    echo "   cd apps/web && vercel --prod"
    echo "   cd apps/app && vercel --prod"
    echo "   cd apps/api && vercel --prod"
    exit 1
  fi

  PROJECT_ID_WEB=$(cat apps/web/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
  ORG_ID=$(cat apps/web/.vercel/project.json | grep -oP '(?<="orgId":").*?(?=")')

  PROJECT_ID_APP=$(cat apps/app/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')
  PROJECT_ID_API=$(cat apps/api/.vercel/project.json | grep -oP '(?<="projectId":").*?(?=")')

  echo "✅ Found:"
  echo "   ORG_ID: $ORG_ID"
  echo "   WEB: $PROJECT_ID_WEB"
  echo "   APP: $PROJECT_ID_APP"
  echo "   API: $PROJECT_ID_API"
}

# Get Vercel token
get_vercel_token() {
  echo ""
  echo "🔑 Getting VERCEL_TOKEN..."
  echo ""
  echo "Create one at: https://vercel.com/account/tokens"
  echo "Then paste it below:"
  echo ""
  read -p "VERCEL_TOKEN: " VERCEL_TOKEN

  if [ -z "$VERCEL_TOKEN" ]; then
    echo "❌ Token required"
    exit 1
  fi

  # Validate token format
  if ! [[ "$VERCEL_TOKEN" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "⚠️  Token looks invalid, but continuing..."
  fi
}

# Add GitHub secrets
add_github_secrets() {
  echo ""
  echo "🔐 Adding GitHub Secrets..."

  gh secret set VERCEL_TOKEN --body "$VERCEL_TOKEN" 2>&1 | grep -q "secret" || true
  gh secret set VERCEL_ORG_ID --body "$ORG_ID" 2>&1 | grep -q "secret" || true
  gh secret set VERCEL_PROJECT_ID_WEB --body "$PROJECT_ID_WEB" 2>&1 | grep -q "secret" || true
  gh secret set VERCEL_PROJECT_ID_APP --body "$PROJECT_ID_APP" 2>&1 | grep -q "secret" || true
  gh secret set VERCEL_PROJECT_ID_API --body "$PROJECT_ID_API" 2>&1 | grep -q "secret" || true

  echo "   ✅ VERCEL_TOKEN"
  echo "   ✅ VERCEL_ORG_ID"
  echo "   ✅ VERCEL_PROJECT_ID_WEB"
  echo "   ✅ VERCEL_PROJECT_ID_APP"
  echo "   ✅ VERCEL_PROJECT_ID_API"
}

# Show next steps
show_final_steps() {
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "✨ Setup Complete! Next Steps:"
  echo "════════════════════════════════════════════════════════════════"
  echo ""
  echo "📌 1️⃣  Add Environment Variables to Vercel"
  echo ""
  echo "   Go to: https://vercel.com/armelgeeks-projects"
  echo ""
  echo "   For EACH project (web, app, api):"
  echo "   Settings → Environment Variables → Add:"
  echo ""
  echo "   ┌─ Web Project ─────────────────────────────────┐"
  echo "   │ NEXT_PUBLIC_APP_URL=https://cv-optimizer*.app │"
  echo "   │ NEXT_PUBLIC_WEB_URL=https://web*.vercel.app  │"
  echo "   │ NEXT_PUBLIC_API_URL=https://api*.vercel.app  │"
  echo "   └────────────────────────────────────────────────┘"
  echo ""
  echo "   ┌─ App Project ──────────────────────────────────┐"
  echo "   │ DATABASE_URL=postgresql://...neon.tech/...     │"
  echo "   │ ANTHROPIC_API_KEY=sk-ant-...                   │"
  echo "   │ SERPAPI_KEY=...                                │"
  echo "   │ STRIPE_SECRET_KEY=sk_live_...                  │"
  echo "   │ STRIPE_WEBHOOK_SECRET=whsec_...                │"
  echo "   │ BETTER_AUTH_SECRET=min-32-chars-random         │"
  echo "   │ BETTER_AUTH_URL=https://cv-optimizer*.app      │"
  echo "   │ + NEXT_PUBLIC_* (same as Web)                  │"
  echo "   └────────────────────────────────────────────────┘"
  echo ""
  echo "   ┌─ API Project ──────────────────────────────────┐"
  echo "   │ (Same as App, without NEXT_PUBLIC_*)           │"
  echo "   └────────────────────────────────────────────────┘"
  echo ""
  echo "📌 2️⃣  Push to main to trigger auto-deploy"
  echo ""
  echo "   git push origin main"
  echo ""
  echo "   Watch at: https://github.com/armelgeek/cv-optimizer/actions"
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "🚀 Your CI/CD pipeline is ready!"
  echo ""
  echo "   Workflow: push main → GitHub CI → Vercel Deploy"
  echo "════════════════════════════════════════════════════════════════"
  echo ""
}

# Main
check_tools
extract_vercel_info
get_vercel_token
add_github_secrets
show_final_steps
