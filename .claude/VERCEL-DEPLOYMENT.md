# Vercel Deployment Setup

## Overview

CV Optimizer deploys 3 separate apps to Vercel:
- **Web** (Marketing site, port 3001) → `vercel-web-cv-optimizer.vercel.app`
- **App** (Main SaaS, port 3000) → `cv-optimizer.vercel.app`
- **API** (Backend server, port 3002) → `api-cv-optimizer.vercel.app`

Each app has its own Vercel project and auto-deploys on push to `main`.

## Setup (One-Time)

### 1. Create Vercel Projects

```bash
# For each app (web, app, api), run:
vercel --prod

# Or manually:
# 1. vercel.com → Add New → Project
# 2. Import GitHub → Select armelgeek/cv-optimizer
# 3. Set Framework: Next.js
# 4. Set Working Directory: apps/web (or apps/app, apps/api)
# 5. Deploy
```

### 2. Get Project IDs

After creating each project, get the IDs:

```bash
# Web project
vercel projects ls | grep web

# App project  
vercel projects ls | grep app

# API project
vercel projects ls | grep api
```

### 3. Add GitHub Secrets

Go to repo settings → Secrets → New repository secret:

```
VERCEL_TOKEN          → Get from vercel.com/account/tokens
VERCEL_ORG_ID         → From your Vercel account URL
VERCEL_PROJECT_ID_WEB → From Web project
VERCEL_PROJECT_ID_APP → From App project
VERCEL_PROJECT_ID_API → From API project
```

### 4. Environment Variables

For each Vercel project, add secrets:

**Web Project:**
```
NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app
NEXT_PUBLIC_WEB_URL=https://web-cv-optimizer.vercel.app
NEXT_PUBLIC_API_URL=https://api-cv-optimizer.vercel.app
```

**App Project:**
```
DATABASE_URL=postgresql://...neon.tech/...
ANTHROPIC_API_KEY=sk-ant-...
SERPAPI_KEY=...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
BETTER_AUTH_SECRET=min-32-chars-random
BETTER_AUTH_URL=https://cv-optimizer.vercel.app

NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app
NEXT_PUBLIC_WEB_URL=https://web-cv-optimizer.vercel.app
NEXT_PUBLIC_API_URL=https://api-cv-optimizer.vercel.app
```

**API Project:**
```
DATABASE_URL=postgresql://...neon.tech/...
ANTHROPIC_API_KEY=sk-ant-...
SERPAPI_KEY=...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
BETTER_AUTH_SECRET=min-32-chars-random

NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app
NEXT_PUBLIC_WEB_URL=https://web-cv-optimizer.vercel.app
NEXT_PUBLIC_API_URL=https://api-cv-optimizer.vercel.app
```

## Workflows

### CI/CD Pipeline

**Push to main** → GitHub Actions CI → Vercel Deploy

**CI** (`.github/workflows/ci.yml`):
- Lint & Typecheck
- Tests
- Build check

**Deploy** (`.github/workflows/deploy.yml`):
- Deploys web, app, api in parallel
- Requires: VERCEL_TOKEN, VERCEL_ORG_ID, Project IDs

### Manual Deploy

```bash
# Deploy web
vercel --prod --scope armel-geek --cwd apps/web

# Deploy app
vercel --prod --scope armel-geek --cwd apps/app

# Deploy api
vercel --prod --scope armel-geek --cwd apps/api
```

## Configuration Files

### `vercel.json`
- Build/install commands
- Function runtime (Node.js 20.x for API)
- Max duration: 30s
- Regions: CDG (Paris), IAD (Virginia)
- Environment variable templates (use Vercel secrets)

### `.vercelignore`
- Ignores unnecessary files (node_modules, .git, etc)
- Keeps deployment fast & clean

### `.github/workflows/ci.yml`
- Lint, typecheck, test on PR + push
- Build check before deploy
- Does NOT deploy (just validates)

### `.github/workflows/deploy.yml`
- Runs ONLY on push to main/master
- Deploys all 3 apps in parallel
- Requires all secrets configured

## Monitoring

### Logs
```bash
# View deployment logs
vercel logs --follow

# View live logs
vercel logs --follow <deployment-url>
```

### Analytics
- vercel.com → Project → Analytics
- Watch for: build time, function execution, cold starts

## Troubleshooting

### Deployment fails in GitHub Actions
1. Check secrets: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID_*`
2. Check working directory is correct
3. View logs: GitHub → Actions → Deploy workflow → Logs

### "Environment variable not found"
1. Add to Vercel project (not GitHub)
2. Or reference in `.env.example` → Vercel auto-loads

### Build takes too long
1. Check `.vercelignore` includes heavy folders
2. View build logs: vercel.com → Project → Deployments
3. Optimize: split bundle, lazy load, cache

### Database migrations fail in production
1. Environment: `DATABASE_URL` must be production connection
2. Migrations: `pnpm db:push` runs in Vercel build (auto)
3. Verify: Check Neon console for applied migrations

## DNS & Custom Domains

### Point domain to Vercel
```
# For cv-optimizer.com (App project)
Type: CNAME
Name: @
Value: cname.vercel.com.
```

### Configure in Vercel
- vercel.com → Project → Settings → Domains
- Add custom domain
- Verify DNS

---

**Last updated:** 2026-08-07
