---
name: Applications Tracker ("Mes Applications")
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001]
parallel: true
conflicts_with: []
---

# Task 6: Applications Tracker ("Mes Applications")

## Description

Build `/applications` page: table of user's saved applications (title, company, date, status, score), click-to-modal with full details, status selector dropdown, "Generate follow-up email" button (template copy-to-clipboard), 3/month limit tracking.

**Route:** `apps/app/app/applications/`  
**Components:** ApplicationsTable, ApplicationModal, StatusSelector  
**Data flow:** DB query → table display → click row → modal with CRUD ops

## Acceptance Criteria
- [ ] Page renders at `/applications` (authenticated only)
- [ ] Table displays:
  - [ ] Columns: Job Title, Company, Applied Date, Status, Match Score
  - [ ] Sort by date (newest first)
  - [ ] Clickable rows open modal
- [ ] Modal displays:
  - [ ] Job title, company, full job posting text
  - [ ] Optimized CV preview (if saved)
  - [ ] Match score + explanation
  - [ ] Interview Q&A section
  - [ ] Status dropdown (Applied/Interviewing/Rejected/Offer/Archived)
- [ ] Status update immediately persists to DB
- [ ] "Generate Follow-up Email" button:
  - [ ] Checks 3/month limit (Task 8)
  - [ ] Calls Claude to generate template (French, professional tone)
  - [ ] Displays template in modal with copy-to-clipboard button
  - [ ] Manual copy + send (no auto-send)
  - [ ] Increments follow_up_emails_this_month counter
- [ ] Empty state: "No applications yet. Start by optimizing an offer!"
- [ ] Responsive design
- [ ] Server actions tested: `listApplications()`, `updateStatus()`, `generateFollowUpEmail()`

## Technical Details

### File Structure
```
apps/app/app/applications/
├── page.tsx                       (main page, fetch + render)
├── components/
│   ├── applications-table.tsx    (table component)
│   ├── application-modal.tsx     (detail modal + status update)
│   └── status-updater.tsx        (status dropdown)
└── actions.ts                    (listApplications, updateStatus, generateFollowUpEmail)
```

### Server Actions
```typescript
export async function listApplications(): Promise<Application[]>
  // Query applications WHERE user_id = current_user, ordered by created_at DESC

export async function updateApplicationStatus(appId: string, status: string): Promise<void>
  // Update applications SET status = ? WHERE id = ?

export async function generateFollowUpEmail(appId: string): Promise<{template: string}>
  // Check follow_up_emails_this_month < 3
  // Call Claude: "Generate French follow-up email for {company} {job_title}"
  // Increment counter
  // Return template
```

## Dependencies
- Task 1 (applications table, users.follow_up_emails_this_month)
- Task 3 (generateFollowUpTemplate from Claude - needs to be added to Task 3)
- Task 8 (quota check for follow-up generation)
- BetterAuth for session

## Effort Estimate
- Size: M
- Hours: 2

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
