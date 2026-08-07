---
name: CV Analysis Page ("Analyse CV")
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: [001, 003]
parallel: true
conflicts_with: []
---

# Task 7: CV Analysis Page ("Analyse CV")

## Description

Build `/cv-analysis` page: PDF upload → Claude analysis (structure, ATS compliance, keywords, gaps) → feedback display → export PDF option (1 credit). Weekly limit: 1 free analysis per user (reset weekly).

**Route:** `apps/app/app/cv-analysis/`  
**Components:** CVUpload (reuse from Task 5), FeedbackDisplay  
**Data flow:** Upload → Claude analysis (Task 3) → Save to cv_analyses table → Display + "Export" button (paywall)

## Acceptance Criteria
- [ ] Page renders at `/cv-analysis` (authenticated only)
- [ ] CV upload component (reuse CVUpload from Task 5):
  - [ ] PDF file input
  - [ ] Error on non-PDF files
- [ ] Analysis flow:
  - [ ] Check if last_cv_analysis_date > 7 days ago (weekly limit)
  - [ ] If limit exceeded: show "Already analyzed this week. Try again on [date]"
  - [ ] Call Claude analyzeCv() (Task 3)
  - [ ] Save to cv_analyses table with feedback
  - [ ] Display feedback structured:
    - [ ] Structure/formatting observations
    - [ ] ATS compliance issues
    - [ ] Missing keywords for job market
    - [ ] Detected gaps
    - [ ] Recommended improvements
- [ ] "Export PDF" button:
  - [ ] Costs 1 credit (paywall check, Task 8)
  - [ ] Generates PDF with full feedback + branding
  - [ ] Download to user's computer
- [ ] Responsive design
- [ ] Server actions: `analyzeCv(cvText)`, `exportAnalysis(analysisId)`

## Technical Details

### File Structure
```
apps/app/app/cv-analysis/
├── page.tsx                  (form + results)
├── components/
│   ├── cv-upload.tsx        (reuse from Task 5)
│   └── feedback-display.tsx (structured feedback + export button)
└── actions.ts               (analyzeCv, exportAnalysis)
```

### Server Actions
```typescript
export async function analyzeCv(cvText: string): Promise<{
  analysisId: string
  feedback: string
  export_costs: number // 1 credit to export
}>

export async function exportAnalysis(analysisId: string): Promise<Blob>
  // Generate PDF from cv_analyses.feedback
  // Return Blob for download
```

### Claude Feedback Structure
```typescript
type CVFeedback = {
  structure?: string[]       // Formatting, sections, organization
  ats_compliance?: string[]  // ATS scanner findings (spacing, formatting, special chars)
  keywords?: string[]        // Missing industry keywords
  gaps?: string[]            // Experience/skill gaps
  recommendations?: string[] // Actionable improvements
}
```

## Dependencies
- Task 1 (cv_analyses table, users.last_cv_analysis_date)
- Task 3 (analyzeCv from Claude)
- Task 8 (paywall gate on export)
- PDF generation library (jsPDF)
- BetterAuth for session

## Effort Estimate
- Size: M
- Hours: 1.5

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
