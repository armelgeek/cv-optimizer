---
name: Testing, Polish & Documentation
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [004, 005, 006, 007, 008, 009, 010, 011]
parallel: false
conflicts_with: []
---

# Task 12: Testing, Polish & Documentation

## Description

Manual e2e flow testing (discovery → optimizer → tracker → paywall), bug fixes, UI polish, documentation (README, API docs, deployment checklist).

**Scope:** Post-feature completion validation, final fixes, deployment readiness.

## Acceptance Criteria

### Testing
- [ ] Manual e2e flow (solo developer):
  - [ ] Discovery: Search → See offers → Click offer → Score calculated ✓
  - [ ] Optimizer: Upload CV → Pre-filled job posting → Generate optimized CV + score + Q&A ✓
  - [ ] Save: Click "Save & Download" → Application saved to tracker ✓
  - [ ] Tracker: View application → Update status → Generate follow-up email ✓
  - [ ] Paywall: Exhaust free tier → Paywall appears → Redirect to Stripe ✓
  - [ ] Payment: Complete Stripe checkout → Credits added → Quota reset ✓
- [ ] Free tier logic tested:
  - [ ] Month reset works (change system date, verify quota reset)
  - [ ] Weekly CV analysis limit enforced (try 2x in same week)
  - [ ] 3/month follow-up limit enforced
- [ ] Error scenarios:
  - [ ] SerpAPI failure → cached results + "Last updated 2h ago" banner ✓
  - [ ] Claude rate-limit → "Calculating score..." placeholder ✓
  - [ ] Invalid PDF upload → error message ✓
  - [ ] Unauthenticated access → redirect to login ✓

### Polish
- [ ] UI responsive on mobile (375px width minimum)
- [ ] Dark mode support (Tailwind class-based theming)
- [ ] Loading states: spinners, placeholders, disable buttons during submission
- [ ] Error toasts: clear, actionable messages (French)
- [ ] Empty states: helpful CTAs ("No applications yet. Start by optimizing an offer!")
- [ ] Buttons: 44x44px minimum touch targets (accessibility)
- [ ] Animations: Smooth transitions, no jank
- [ ] Page load time: All pages <3s on 3G (Lighthouse baseline)

### Documentation
- [ ] README.md:
  - [ ] Project overview (what is CV Optimizer 2.0?)
  - [ ] Features (4 pages, credit system, no subscriptions)
  - [ ] Quick start (pnpm install, .env setup, pnpm dev)
  - [ ] Tech stack (Next.js, Drizzle, Claude, SerpAPI, Stripe)
  - [ ] Directory structure (apps/app vs packages/*)
  - [ ] Roadmap (Phase 2 features)
- [ ] .env.example updated with all new variables:
  - [ ] SERPAPI_KEY
  - [ ] ANTHROPIC_API_KEY
  - [ ] STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
  - [ ] CRON_SECRET
- [ ] DEPLOYMENT_CHECKLIST.md:
  - [ ] Environment variables to set in Vercel
  - [ ] Database migrations (pnpm db:push)
  - [ ] Stripe webhook endpoint configuration
  - [ ] Cron job setup (vercel.json)
  - [ ] Analytics (PostHog) configuration
  - [ ] DNS/domain setup (if custom domain)
  - [ ] Security: API key rotation, CORS headers
  - [ ] Monitoring: PostHog dashboards, error logging
- [ ] Code comments:
  - [ ] Only WHY comments (non-obvious logic, constraints, workarounds)
  - [ ] No WHAT comments (code is self-documenting)

### Final Checks
- [ ] TypeScript strict mode: `pnpm typecheck` passes ✓
- [ ] Linting: `pnpm check` passes ✓
- [ ] No secrets committed (grep for API keys, passwords)
- [ ] Git history clean: meaningful commit messages
- [ ] All tasks merged to main branch
- [ ] GitHub Issues/PRs closed

## Technical Details

### Files to Create/Update
```
- README.md (new)
- DEPLOYMENT_CHECKLIST.md (new)
- .env.example (update)
- docs/ARCHITECTURE.md (optional, if complex)
- docs/API.md (optional, internal APIs)
```

### Testing Checklist (Manual)
```markdown
## Discovery Flow
- [ ] Search "Développeur Python" + "Paris" → results appear
- [ ] Click "Score" button → score calculated + cached
- [ ] Click "Optimize" → redirects to /optimizer/[jobId]
- [ ] Free tier exhausted → paywall appears

## Optimizer Flow
- [ ] Upload PDF CV → preview shows
- [ ] Job posting pre-filled → matches discovery
- [ ] Generate → Claude processes (placeholder visible)
- [ ] Results appear: CV preview (tabs), score, interview Q&A
- [ ] Save & Download → application saved, PDF generated
- [ ] First upsell moment appears

## Tracker Flow
- [ ] Application appears in /applications table
- [ ] Click row → modal opens
- [ ] Change status → persists immediately
- [ ] Generate follow-up → template appears, copy works
- [ ] Try 4th follow-up → error "Limit reached"

## Paywall Flow
- [ ] Buy 30 credits → Stripe checkout opens
- [ ] Complete payment → redirected to /optimizer
- [ ] Credits added to account
- [ ] Quota reset allows new optimizations

## Edge Cases
- [ ] Double-click save → only one application created
- [ ] Refresh during Claude generation → continues
- [ ] SerpAPI timeout → cached results + banner
- [ ] Logout + login → user's data still there
```

## Dependencies
- All prior tasks (1–11) complete and working

## Effort Estimate
- Size: M
- Hours: 2

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
