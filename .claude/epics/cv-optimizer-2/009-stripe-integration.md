---
name: Stripe Payment Integration
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [008]
parallel: false
conflicts_with: []
---

# Task 9: Stripe Payment Integration

## Description

Integrate Stripe one-time checkout for credit packs. Create checkout session on user request, webhook handler to credit user on payment_intent.succeeded, store transaction log.

**Deliverables:**
1. Stripe API client in `packages/credits/src/stripe-provider.ts`
2. Checkout session creation endpoint
3. Webhook handler at `/api/webhooks/stripe`
4. Transaction logging in database
5. Environment variables configured (STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET)

## Acceptance Criteria
- [ ] `packages/credits/` package created with:
  - [ ] `stripe-provider.ts`: `createCheckoutSession(userId, creditPack, priceId)`
  - [ ] Returns {sessionId, checkoutUrl}
- [ ] Server action in app (e.g., `apps/app/lib/stripe-actions.ts`):
  - [ ] `initiateCheckout(creditPack: number): Promise<{checkoutUrl: string}>`
- [ ] Webhook handler at `/api/webhooks/stripe`:
  - [ ] Verifies Stripe signature (STRIPE_WEBHOOK_SECRET)
  - [ ] Listens for checkout.session.completed event
  - [ ] Extracts userId + creditPack from session.metadata
  - [ ] Calls `subtractCredit(userId, -creditPack)` (negative to add)
  - [ ] Logs transaction: {user_id, credits, amount_paid, status, created_at}
  - [ ] Responds 200 on success
- [ ] Stripe environment variables set:
  - [ ] STRIPE_SECRET_KEY (sk_test_...)
  - [ ] STRIPE_PUBLISHABLE_KEY (pk_test_...)
  - [ ] STRIPE_WEBHOOK_SECRET (whsec_...)
- [ ] Paywall modal (Task 8) "Acheter des crédits" button triggers checkout
- [ ] Success page redirect: `/optimizer?session_id={CHECKOUT_SESSION_ID}`
- [ ] Error handling: network failures, invalid credit pack, webhook replay
- [ ] TypeScript strict

## Technical Details

### File Structure
```
packages/credits/
├── package.json
├── src/
│   ├── types.ts          (CreditPack, Transaction types)
│   ├── stripe-provider.ts (Stripe client, checkout + webhook logic)
│   └── index.ts          (exports)

apps/api/
├── routes/webhooks/stripe.ts (Webhook endpoint)
└── ...

apps/app/lib/
└── stripe-actions.ts (Server action for initiating checkout)
```

### API Shape
```typescript
// Stripe provider
type CreditPack = { credits: number; price: string; priceId: string }

export async function createCheckoutSession(
  userId: string,
  creditPack: number,
  priceId: string
): Promise<{sessionId: string; checkoutUrl: string}>

export async function handleStripeWebhook(
  event: Stripe.Event,
  onPaymentSuccess: (userId: string, creditPack: number) => Promise<void>
): Promise<void>

// Server action
export async function initiateCheckout(
  creditPack: 10 | 30 | 60
): Promise<{checkoutUrl: string}>
```

### Webhook Flow
1. User clicks "Acheter des crédits" in Paywall modal
2. Calls `initiateCheckout(30)` → creates Stripe session → redirects to checkout
3. User completes payment in Stripe
4. Stripe sends POST to `/api/webhooks/stripe`
5. Webhook extracts userId + creditPack from metadata
6. Adds credits to users.credits_balance
7. Logs transaction
8. Success: user redirected to `/optimizer` with toast "Credits added!"

## Dependencies
- Task 8 (credit gates, paywall modal, subtractCredit)
- Stripe SDK (@stripe/stripe-js, stripe Node package)
- STRIPE_SECRET_KEY + STRIPE_WEBHOOK_SECRET env vars

## Effort Estimate
- Size: M
- Hours: 1.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
