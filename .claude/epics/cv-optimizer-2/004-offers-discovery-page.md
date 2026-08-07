---
name: Offers Discovery Page ("Offres pour moi")
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001, 002]
parallel: true
conflicts_with: []
---

# Task 4: Offers Discovery Page

## Description

Build the `/offers` landing page: sidebar filters (search, location, job type), paginated job feed from SerpAPI, match score display per card, "Optimize" button routing to `/optimizer/[jobId]`.

**Route:** `apps/app/app/offers/`  
**Components:** JobCard, FiltersSidebar, pagination  
**Data flow:** Filters → `fetchOffers()` server action → cache/SerpAPI → display cards with cached scores

## Acceptance Criteria
- [ ] Page renders at `/offers` (authenticated only)
- [ ] Sidebar filters working:
  - [ ] Search box (text input for job title)
  - [ ] Location input
  - [ ] Job type dropdown (CDI/Stage/Contract/Freelance)
  - [ ] "Clear filters" button
- [ ] Job feed displays ~10 results per page
- [ ] JobCard shows: title, company, location, salary (if available), **match score badge**
- [ ] Match score calculated on-demand via Claude (Task 3 integration)
- [ ] Score cached per user per job (24h TTL)
- [ ] "Optimize" button clicks trigger paywall check (Task 8)
- [ ] On SerpAPI failure: show cached results + "Updated X hours ago" banner
- [ ] Responsive design (mobile-friendly)
- [ ] Server actions tested: `fetchOffers(query, location)`, `getMatchScore(jobId, cvText)`

## Technical Details

### File Structure
```
apps/app/app/offers/
├── page.tsx               (main page, client component)
├── layout.tsx             (auth guard, sidebar wrap)
├── components/
│   ├── job-card.tsx       (JobCard component, score calculation)
│   ├── filters-sidebar.tsx (FiltersSidebar, search + filters)
│   └── pagination.tsx     (pagination controls)
└── actions.ts             (fetchOffers, getMatchScore server actions)
```

### Server Actions
```typescript
export async function fetchOffers(query: string, location: string) {
  // Query job_search_cache (mutualised), cache hit returns cached
  // On miss: call SerpAPI via jobs-provider (Task 2)
  // Cache result, return jobs
}

export async function getMatchScore(jobId: string, cvText: string) {
  // Check user quota (Task 8)
  // Call Claude via claude-integration (Task 3)
  // Cache score 24h per user
  // Return {score, explanation}
}
```

## Dependencies
- Task 1 (discovered_jobs table, job_search_cache)
- Task 2 (JobProvider, getOrFetchJobs)
- Task 3 (getMatchScore from Claude)
- Task 8 (paywall gates for "Optimize" button)
- BetterAuth for session
- Shadcn UI components

## Effort Estimate
- Size: M
- Hours: 2

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
