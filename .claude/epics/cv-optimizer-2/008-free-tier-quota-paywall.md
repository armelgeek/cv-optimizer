---
name: Free Tier Quota Logic & Paywall Modal
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001]
parallel: false
conflicts_with: []
---

# Task 8: Free Tier Quota Logic & Paywall Modal

## Description

Implement credit quota enforcement: track free-tier usage (1 optimization/month, 1 CV analysis/week, 3 follow-ups/month), display paywall modal when limits exhausted, expose `isActionAllowed()` + `subtractCredit()` helpers.

**Deliverables:**
1. Credit gate functions: `isActionAllowed()`, `subtractCredit()`
2. Paywall modal component (reused across all pages)
3. Quota tracking in user table (free_uses_this_month, last_cv_analysis_date, follow_up_emails_this_month)

## Acceptance Criteria
- [ ] `lib/credit-gates.ts` exports:
  - [ ] `isActionAllowed(userId, 'optimize' | 'analyze' | 'follow_up'): Promise<boolean>`
  - [ ] `subtractCredit(userId, amount): Promise<void>`
- [ ] Monthly reset logic:
  - [ ] Check if free_uses_reset_date < first day of current month
  - [ ] Reset free_uses_this_month = 1 (optimization quota)
  - [ ] Reset follow_up_emails_this_month = 0
- [ ] Paywall modal component (`components/paywall.tsx`):
  - [ ] Displays credit packs (10@€6.99, 30@€14.99, 60@€24.99)
  - [ ] Select pack radio buttons (30 recommended by default)
  - [ ] "Acheter des crédits" button → redirect to Stripe checkout (Task 9)
  - [ ] "Plus tard" button → dismiss
  - [ ] Badge: "Aucun abonnement. Pas de renouvellement automatique."
  - [ ] Themed for light/dark mode
- [ ] Integration hooks in all action-guarded pages:
  - [ ] Task 4 (Optimize button) → check `isActionAllowed('optimize')` before action
  - [ ] Task 5 (Save optimized CV) → check before `generateOptimization()`
  - [ ] Task 6 (Generate follow-up) → check `isActionAllowed('follow_up')` before action
  - [ ] Task 7 (Analyze CV) → check `isActionAllowed('analyze')` before action
  - [ ] Task 7 (Export PDF) → check before `subtractCredit()`
- [ ] Error messages in French
- [ ] TypeScript strict

## Technical Details

### File Structure
```
apps/app/lib/
├── credit-gates.ts        (isActionAllowed, subtractCredit)
└── ...

apps/app/components/
├── paywall.tsx            (modal component)
└── ...
```

### API Shape
```typescript
export async function isActionAllowed(
  userId: string,
  action: 'optimize' | 'analyze' | 'follow_up'
): Promise<boolean>

export async function subtractCredit(userId: string, amount: number): Promise<void>
```

### Usage Pattern
```typescript
// In server action
const canOptimize = await isActionAllowed(userId, 'optimize')
if (!canOptimize) throw new Error('Free tier exhausted')
// ... proceed with optimization ...
await subtractCredit(userId, 1) // After successful save
```

## Dependencies
- Task 1 (users table columns: free_uses_this_month, last_cv_analysis_date, follow_up_emails_this_month)
- Task 9 (Stripe checkout session URL)
- BetterAuth for current user

## Effort Estimate
- Size: M
- Hours: 1.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
