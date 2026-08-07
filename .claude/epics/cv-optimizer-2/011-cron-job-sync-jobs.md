---
name: 6-Hourly Cron Job (Job Sync)
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001, 002]
parallel: false
conflicts_with: []
---

# Task 11: 6-Hourly Cron Job (Job Sync)

## Description

Create Vercel background function that runs every 6 hours: fetches popular job searches from SerpAPI, upserts into discovered_jobs table. Maintains fresh job pool for discovery page without user-triggered API calls.

**Route:** `apps/api/routes/cron/sync-jobs.ts`  
**Trigger:** Vercel Crons, 6-hourly (00:00, 06:00, 12:00, 18:00 UTC)  
**Data flow:** Cron job → fetch popular searches → SerpAPI → upsert into DB

## Acceptance Criteria
- [ ] Endpoint created at `apps/api/routes/cron/sync-jobs.ts`
  - [ ] GET handler only (Vercel Crons use GET)
  - [ ] Verifies CRON_SECRET header (Bearer token)
  - [ ] Returns JSON {success, synced, error}
- [ ] Popular searches hardcoded (expand to dynamic in Phase 2):
  - [ ] "Développeur Python" - Paris
  - [ ] "Product Manager" - Île-de-France
  - [ ] "Designer UX" - Lyon
  - [ ] "Data Scientist" - Remote (France-based)
  - [ ] (5–8 total searches for start)
- [ ] For each search:
  - [ ] Call `getJobProvider().search(query, location)`
  - [ ] Upsert each job into discovered_jobs table (match on google_job_id)
  - [ ] Update expires_at timestamp
- [ ] Error handling:
  - [ ] SerpAPI failure → log + continue (don't break loop)
  - [ ] DB upsert failure → log + return error
  - [ ] Rate-limit backoff (if SerpAPI 429, pause & retry once)
- [ ] vercel.json configured with cron schedule:
  - [ ] Path: `/api/cron/sync-jobs`
  - [ ] Schedule: `0 */6 * * *` (every 6 hours)
- [ ] CRON_SECRET env var set in Vercel dashboard
- [ ] Logging via PostHog / console for monitoring

## Technical Details

### File Structure
```
apps/api/routes/
└── cron/
    └── sync-jobs.ts    (Cron job handler)

vercel.json (update with cron config)
```

### Endpoint
```typescript
// GET /api/cron/sync-jobs
// Header: Authorization: Bearer <CRON_SECRET>
// Response: {success: boolean, synced: number, error?: string}

export async function GET(req: NextRequest) {
  const auth = req.headers.get('authorization')
  if (auth !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({error: 'Unauthorized'}, {status: 401})
  }

  const jobs = await getJobProvider().search(query, location)
  for (const job of jobs) {
    await db.insert(discoveredJobs).values({...}).onConflictDoUpdate({...})
  }
  
  return NextResponse.json({success: true, synced: jobs.length})
}
```

### vercel.json Config
```json
{
  "crons": [
    {
      "path": "/api/cron/sync-jobs",
      "schedule": "0 */6 * * *"
    }
  ]
}
```

## Dependencies
- Task 1 (discovered_jobs table)
- Task 2 (JobProvider, getJobProvider())
- CRON_SECRET env var
- Vercel Functions (built-in, no extra setup)

## Effort Estimate
- Size: S
- Hours: 1

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
