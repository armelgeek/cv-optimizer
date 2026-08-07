# CV Optimizer - Deployment Checklist

## ✅ Completed Steps

- [x] Vercel projects created (web, app, api)
- [x] GitHub Secrets configured (VERCEL_TOKEN, ORG_ID, PROJECT_IDs)
- [x] GitHub Actions workflows active (CI + Deploy)
- [x] Database migrations configured (Neon + auto-migration)
- [x] pnpm support configured in Vercel
- [x] Scripts automated (setup, finalization)

## ⏳ Next: Manual Configuration (5-10 min)

### Step 1️⃣ Rename Vercel Projects for Clean URLs

**Option A: Via Script (Automated)**
```bash
bash .github/FINALIZE_VERCEL.sh
# Asks for VERCEL_TOKEN, renames all 3 projects automatically
```

**Option B: Manual (Vercel Console)**
1. Go to https://vercel.com/dashboard/projects
2. For each project, click Settings → Name:
   - Rename `app` → `cv-optimizer`
   - Rename `web` → `web-cv-optimizer`
   - Rename `api` → `api-cv-optimizer`

**Result:**
```
cv-optimizer.vercel.app
web-cv-optimizer.vercel.app
api-cv-optimizer.vercel.app
```

### Step 2️⃣ Add Environment Variables to Vercel

For **each project**, click Settings → Environment Variables → Add:

#### All 3 Projects (Web, App, API)
```
NEXT_PUBLIC_APP_URL = https://cv-optimizer.vercel.app
NEXT_PUBLIC_WEB_URL = https://web-cv-optimizer.vercel.app
NEXT_PUBLIC_API_URL = https://api-cv-optimizer.vercel.app
```

#### App & API Projects ONLY (in addition to above)
```
DATABASE_URL = postgresql://neondb_owner:npg_N37nqaVZgBCj@ep-divine-violet-axjoug9r.c-4.us-east-2.aws.neon.tech/neondb?sslmode=require

ANTHROPIC_API_KEY = sk-ant-...
SERPAPI_KEY = ...
STRIPE_SECRET_KEY = sk_live_...
STRIPE_WEBHOOK_SECRET = whsec_...

BETTER_AUTH_SECRET = dev-secret-key-change-in-production-min32chars
BETTER_AUTH_URL = https://cv-optimizer.vercel.app
```

**Get values from:**
- `.env.local` in repo (copy production values here)
- Neon console for DATABASE_URL
- Your service provider dashboards (Anthropic, SerpAPI, Stripe)

### Step 3️⃣ Trigger First Deployment

Once env vars are added:

```bash
git push origin main
```

Watch deployment:
- GitHub Actions: https://github.com/armelgeek/cv-optimizer/actions
- Vercel: https://vercel.com/dashboard/projects

### Step 4️⃣ Verify Everything Works

After deployment completes:

- [ ] Test App: https://cv-optimizer.vercel.app
- [ ] Test Web: https://web-cv-optimizer.vercel.app
- [ ] Test API: https://api-cv-optimizer.vercel.app (should return JSON)
- [ ] Check database connection in Neon console

## 🚀 Auto-Deploy Pipeline Active

From now on, every push to `main` auto-deploys:

```
git push origin main
    ↓
GitHub Actions (Lint → Typecheck → Test → Build)
    ↓
Vercel Auto-Deploy (Web, App, API in parallel)
    ↓
Production live ✨
```

**No manual action needed!**

## 🔧 Troubleshooting

**Deployment fails?**
1. Check GitHub Actions logs: https://github.com/armelgeek/cv-optimizer/actions
2. Check Vercel logs: Vercel Dashboard → Project → Deployments
3. Verify env vars are set (not typos in keys)

**Database connection error?**
1. Verify DATABASE_URL is correct (from Neon console)
2. Check that Neon connection string is for production (direct endpoint, not pooler)
3. Confirm migrations ran: `pnpm db:studio`

**"Module not found" errors?**
1. Ensure all dependencies are in package.json
2. Check workspace dependencies use `workspace:*` protocol
3. Verify pnpm-lock.yaml is committed

---

**Status:** Ready for deployment  
**Next Action:** Run Step 1️⃣ through Step 3️⃣ above  
**Estimated Time:** 5-10 minutes
