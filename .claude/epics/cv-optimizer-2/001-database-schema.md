---
name: Database Schema & Migrations
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: []
parallel: false
conflicts_with: []
---

# Task 1: Database Schema & Migrations

## Description

Define 5 new database tables (discovered_jobs, applications, cv_analyses, job_search_cache, users modifications) using Drizzle ORM. Generate and push migrations to PostgreSQL.

**Tables:**
- `discovered_jobs`: Job postings from SerpAPI (google_job_id, title, company, location, salary, job_type, URL, expires_at)
- `applications`: Saved applications per user (user_id, job_title, company, optimized_cv, match_score, interview_questions, status)
- `cv_analyses`: CV health check results (user_id, uploaded_cv, feedback, created_at)
- `job_search_cache`: Mutualised SerpAPI cache (query_hash, response, expires_at)
- `users` (modified): Add free_uses_this_month, free_uses_reset_date, last_cv_analysis_date, follow_up_emails_this_month

## Acceptance Criteria
- [ ] 5 tables defined in `packages/database/src/schema.ts`
- [ ] Migration file generated via drizzle-kit
- [ ] Migration pushed to dev database successfully
- [ ] Schema verified in Drizzle Studio
- [ ] All columns typed correctly (UUID PKs, timestamps, enums for job_type/status)
- [ ] Indexes added for frequent queries (user_id, query_hash, expires_at)
- [ ] Foreign keys configured correctly

## Technical Details

### Schema Overview
```typescript
discovered_jobs {
  id: UUID PK
  google_job_id: varchar UNIQUE
  title, company, location: varchar
  job_posting_text: text
  salary_min, salary_max: int nullable
  job_type: enum (CDI, Stage, Contract, Freelance)
  job_url: text
  created_at, expires_at: timestamp
}

applications {
  id: UUID PK
  user_id: UUID FK
  discovered_job_id: UUID FK nullable
  job_title, company: varchar
  job_posting_text: text
  optimized_cv: text nullable
  cv_match_score: int nullable (0-100)
  interview_questions: jsonb nullable
  status: enum (applied, interviewing, rejected, offer, archived)
  created_at, updated_at: timestamp
}

cv_analyses {
  id: UUID PK
  user_id: UUID FK
  uploaded_cv: text (base64 or path)
  feedback: text
  created_at: timestamp
}

job_search_cache {
  id: UUID PK
  query_hash: varchar UNIQUE (SHA256 of title+location)
  serpapi_response: jsonb
  fetched_at, expires_at: timestamp
}

users (add columns) {
  free_uses_this_month: int DEFAULT 1
  free_uses_reset_date: date nullable
  last_cv_analysis_date: date nullable
  follow_up_emails_this_month: int DEFAULT 0
}
```

## Dependencies
- Drift/packages/database setup
- PostgreSQL connection via DATABASE_URL

## Effort Estimate
- Size: M
- Hours: 1.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
