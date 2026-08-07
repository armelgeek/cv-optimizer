---
name: 5 Upsell Moments (Conversion Triggers)
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [009]
parallel: false
conflicts_with: []
---

# Task 10: 5 Upsell Moments

## Description

Place 5 context-aware CTAs to drive credit purchases at natural friction points: after first optimization, free tier exhausted, browsing 5+ offers, 8+ applications saved, first purchase bonus.

**Triggers:**
1. After first optimization → "You just created your first tailored CV! Explore 50+ offers that match your profile."
2. Free tier exhausted → "You've used your free trial this month. Ready to explore more?"
3. Browsed 5+ offers → "Interested in 3+ offers? Buy credits to optimize all of them."
4. 8+ applications in tracker → "You've applied to 8 offers. Optimize more to increase your chances. 30 credits for €14.99"
5. First purchase bonus → "Buy 10 credits, get 12 free" (time-limited impulse offer, separate from Task 9)

## Acceptance Criteria
- [ ] Upsell component created: `components/upsell-moments.tsx`
  - [ ] Types: UpsellContext (trigger, userCredits, appCount, etc.)
  - [ ] Message map for each trigger (French copy)
- [ ] Trigger 1: After first optimization
  - [ ] Check if `userApplications.length === 0` in `optimizer/actions.ts`
  - [ ] Return upsellTrigger in response
  - [ ] Show floating CTA: "Tu viens de créer..." + Paywall modal
- [ ] Trigger 2: Free tier exhausted
  - [ ] Embed in Paywall modal when quota check fails
  - [ ] Message: "Tu as utilisé ton essai gratuit ce mois-ci..."
- [ ] Trigger 3: Browsed 5+ offers
  - [ ] Track viewed job count in client state (`/offers` page)
  - [ ] After 5th viewed job, show bottom-right floating button
  - [ ] Message: "Intéressé par 3+ offres?..."
  - [ ] Click → open Paywall modal
- [ ] Trigger 4: 8+ applications in tracker
  - [ ] Check `applications.length >= 8` in `/applications` page
  - [ ] Show floating banner: "Tu as candidaté à 8 offres..."
  - [ ] Click → open Paywall modal
- [ ] Trigger 5: First purchase bonus
  - [ ] Add checkbox to Paywall: "First purchase? Get 12 credits free!"
  - [ ] Logic: detect if user.total_credits_purchased === 0
  - [ ] Apply auto-discount in Stripe session (10 credits → 22 free tier)
  - [ ] OR: 30 credits pack shows "+20 bonus" label if first purchase
  - [ ] Time limit: Only show for 30 days after user creates account
- [ ] CSS: Floating buttons don't overlap main content, dismissible
- [ ] Responsive design (mobile-friendly placement)
- [ ] Analytics: PostHog event on each trigger shown + clicked

## Technical Details

### File Structure
```
apps/app/components/
└── upsell-moments.tsx   (UpsellMoment component, trigger logic)

apps/app/app/offers/
└── page.tsx             (Trigger 3: track viewedCount)

apps/app/app/applications/
└── page.tsx             (Trigger 4: check appCount >= 8)

apps/app/app/optimizer/
└── actions.ts           (Trigger 1: return upsellTrigger on first app)

apps/app/components/
└── paywall.tsx          (Trigger 5: show first-purchase bonus, Trigger 2: embed in modal)
```

### UpsellMoment Component Shape
```typescript
type UpsellContext = {
  trigger: 'first-optimization' | 'free-exhausted' | 'many-offers' | 'many-apps' | 'first-purchase-bonus'
  userCredits?: number
  appCount?: number
  offerCount?: number
  daysSinceSignup?: number
}

export function UpsellMoment({context}: {context: UpsellContext}) {
  // Show floating CTA + open Paywall on click
}
```

### Copy (French)
```
1. "Tu viens de créer ton premier CV adapté ! Explore 50+ offres qui matchent ton profil. 10 crédits pour 6,99€"
2. "Tu as utilisé ton essai gratuit ce mois-ci. Prêt à explorer plus ? Achète des crédits"
3. "Intéressé par 3+ offres ? Achète des crédits pour toutes les optimiser"
4. "Tu as candidaté à 8 offres. Optimise-en plus pour augmenter tes chances. 30 crédits pour 14,99€"
5. "10 crédits achetés = 12 offerts. Offre à durée limitée !"
```

## Dependencies
- Task 8 (Paywall modal component)
- Task 9 (Stripe checkout)
- PostHog for event tracking

## Effort Estimate
- Size: S
- Hours: 1

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
