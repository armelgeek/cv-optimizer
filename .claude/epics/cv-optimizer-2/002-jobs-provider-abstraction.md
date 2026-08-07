---
name: Job Provider Abstraction (SerpAPI + Cache)
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001]
parallel: false
conflicts_with: []
---

# Task 2: Job Provider Abstraction (SerpAPI + Cache)

## Description

Create a provider-agnostic job search layer. Implement SerpAPI concrete provider + cache integration. Layer allows swap to Adzuna/Jooble in Phase 2 without major refactor.

**Deliverables:**
1. `packages/jobs-provider/` new package with JobProvider interface
2. SerpAPI implementation with error handling
3. Cache integration via `getOrFetchJobs()` helper
4. Fallback display on SerpAPI failure

## Acceptance Criteria
- [ ] `packages/jobs-provider/package.json` created and linked to workspace
- [ ] `JobProvider` interface defined (search method signature)
- [ ] `Job` type defined (id, title, company, location, posting_text, salary, job_type, url, expires_date)
- [ ] SerpAPI client implemented with:
  - API key from env variable
  - Query params (engine=google_jobs, q, location)
  - Job type parsing (CDI/Stage/Contract/Freelance)
  - Error handling (network, rate-limit, malformed response)
- [ ] `getOrFetchJobs(query, location)` function:
  - Calls `getCachedJobSearch(queryHash)` first (Task 1 dependency)
  - On cache miss: fetches from SerpAPI, caches result with 8h TTL
  - On failure: returns stale cache with "Last updated Xh ago" banner
- [ ] Tested manually against SerpAPI (verify JSON parsing, score extraction)
- [ ] TypeScript strict mode, no `any`

## Technical Details

### File Structure
```
packages/jobs-provider/
├── package.json
├── src/
│   ├── types.ts          (JobProvider interface, Job shape)
│   ├── providers/
│   │   ├── serpapi.ts    (SerpAPI concrete class)
│   │   └── adzuna.ts     (Stub for Phase 2)
│   └── index.ts          (Factory export: getJobProvider())
```

### API Shape
```typescript
interface JobProvider {
  search(query: string, location: string, filters?: JobFilters): Promise<Job[]>
}

type Job = {
  id: string
  title, company, location, posting_text: string
  salary_min?, salary_max?: number
  job_type: 'CDI' | 'Stage' | 'Contract' | 'Freelance'
  url: string
  posted_date, expires_date: string
}
```

## Dependencies
- Task 1 (database schema for cache queries)
- SERPAPI_KEY env variable
- `@repo/database` for cache ops

## Effort Estimate
- Size: M
- Hours: 1.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
