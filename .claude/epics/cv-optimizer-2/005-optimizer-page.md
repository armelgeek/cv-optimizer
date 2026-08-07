---
name: Optimizer Page (Enriched CV Optimization)
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001, 003]
parallel: true
conflicts_with: []
---

# Task 5: Optimizer Page (Enriched)

## Description

Build `/optimizer` and `/optimizer/[jobId]` pages: CV upload (PDF, reuse last or new), job posting textarea or pre-filled from discovery, parallel Claude generation (optimized CV + match score + interview questions), CV preview tabs, "Save & Download" action.

**Route:** `apps/app/app/optimizer/`  
**Components:** CVUpload, CVPreview (Original/Optimized tabs), MatchDisplay, InterviewQA (collapsible)  
**Data flow:** CV → Job posting → Claude parallel gen → Display results → Save to applications table → PDF download

## Acceptance Criteria
- [ ] Pages render at `/optimizer` (generic) and `/optimizer/[jobId]` (pre-filled from discovery)
- [ ] CV upload component:
  - [ ] PDF file input with drag-drop
  - [ ] Reuse last CV checkbox (fetch from user profile)
  - [ ] Error handling (non-PDF files rejected)
- [ ] Job posting textarea or pre-populated from discovery link
- [ ] Parallel Claude generation:
  - [ ] Optimized CV text (naive: append relevant keywords; full rewrite in Phase 2)
  - [ ] Match score + strengths/gaps/explanation (Task 3)
  - [ ] 5 interview questions + suggested answers (Task 3)
  - [ ] Placeholder "Generating..." while Claude processes
- [ ] Preview UI:
  - [ ] Tabs: Original CV | Optimized CV
  - [ ] Match score display (0-100%, explanation, strengths/gaps)
  - [ ] Interview Q&A collapsible section
- [ ] "Save & Download" button:
  - [ ] Saves to applications table (saves optimized CV, match score, interview questions, status='applied')
  - [ ] Generates PDF (optimized CV + score + interview Q&A)
  - [ ] Triggers first upsell moment if first optimization (Task 10)
  - [ ] Redirects to /applications with toast "Application saved!"
- [ ] Cost: 1 credit per optimization (enforced via paywall, Task 8)
- [ ] Responsive design

## Technical Details

### File Structure
```
apps/app/app/optimizer/
├── page.tsx                   (generic optimizer form)
├── [jobId]/
│   └── page.tsx              (pre-filled from discovery)
├── components/
│   ├── cv-upload.tsx         (PDF upload + reuse last)
│   ├── cv-preview.tsx        (Original/Optimized tabs)
│   ├── match-display.tsx     (Score, strengths, gaps)
│   └── interview-qa.tsx      (5 questions, collapsible)
└── actions.ts                (generateOptimization, saveApplication, downloadPdf)
```

### Server Actions
```typescript
export async function generateOptimization(
  cvText: string,
  jobPosting: string,
  jobId?: string
): Promise<{optimizedCv, matchResult, interviewQs}>

export async function saveApplication(
  cvText, optimizedCv, jobTitle, company, matchScore
): Promise<Application>

export async function downloadPdfCV(appId: string): Promise<Blob>
```

## Dependencies
- Task 1 (applications table, users.credits)
- Task 3 (getMatchScore, generateInterviewQuestions from Claude)
- Task 8 (paywall gate on generateOptimization)
- PDF generation library (jsPDF or similar)
- BetterAuth for session

## Effort Estimate
- Size: L
- Hours: 2.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
