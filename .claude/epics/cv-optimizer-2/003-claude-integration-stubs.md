---
name: Claude Integration Stubs (Score, Q&A, Feedback)
status: open
created: 2026-08-07T00:00:00Z
updated: 2026-08-07T00:00:00Z
github: (will be set on sync)
depends_on: []
parallel: true
conflicts_with: []
---

# Task 3: Claude Integration Stubs

## Description

Create `packages/claude-integration/` with 3 deterministic functions for CV-to-job matching, interview preparation, and CV health analysis. All parse Claude responses into structured JSON, with fallback error handling.

**Deliverables:**
1. Match scoring: CV vs Job → {score 0-100, strengths[], gaps[], explanation}
2. Interview questions: Job posting → [{q, suggested_answer}] (5 questions)
3. CV analysis: CV text → structured feedback (formatting, ATS, keywords, gaps)

## Acceptance Criteria
- [ ] `packages/claude-integration/package.json` created
- [ ] 3 functions implemented: `getMatchScore()`, `generateInterviewQuestions()`, `analyzeCv()`
- [ ] Claude API client (@anthropic-ai/sdk) configured with ANTHROPIC_API_KEY
- [ ] JSON response parsing with fallback (if parse fails, return sensible defaults)
- [ ] Haiku model used (cost-efficient)
- [ ] Prompt engineering: French prompts, request JSON-only output (no markdown)
- [ ] Error handling: rate-limit, network, malformed response → log + return error object
- [ ] Rate-limit queuing foundation (placeholder for Task 9 paywall integration)
- [ ] TypeScript strict, exported types

## Technical Details

### File Structure
```
packages/claude-integration/
├── package.json
├── src/
│   ├── types.ts                    (MatchResult, InterviewQ, CVFeedback)
│   ├── score-match.ts              (getMatchScore)
│   ├── interview-questions.ts      (generateInterviewQuestions)
│   ├── cv-analysis.ts              (analyzeCv)
│   ├── follow-up-email.ts          (generateFollowUpTemplate - stub)
│   └── index.ts                    (exports)
```

### API Shape
```typescript
// Match Scoring
type MatchResult = {
  score: number              // 0-100
  strengths: string[]        // CV strengths vs job
  gaps: string[]             // Missing skills/experience
  explanation: string        // Human-friendly summary (French)
}

// Interview Questions
type InterviewQuestion = {
  q: string                  // Question
  suggested_answer?: string  // Talking points
}

// CV Analysis
type CVFeedback = {
  structure?: string[]       // Formatting observations
  ats_compliance?: string[]  // ATS scanner issues
  keywords?: string[]        // Missing keywords for job market
  gaps?: string[]            // Experience gaps identified
  recommendations?: string[] // Actionable improvements
}
```

### Prompt Examples
```
Match scoring: "Analyse le CV et l'offre suivante. Retourne JSON: {score, strengths, gaps, explanation}"
Interview Q&A: "Basé sur cette offre, génère 5 questions d'entretien. Réponds en JSON: {questions: [{q, suggested_answer}]}"
CV analysis: "Analyse ce CV. Retourne JSON: {structure, ats_compliance, keywords, gaps, recommendations}"
```

## Dependencies
- ANTHROPIC_API_KEY env variable
- None (no DB dependency; Task 4-7 will use these functions)

## Effort Estimate
- Size: M
- Hours: 1

## Definition of Done
- [x] Code implemented
- [x] Tests written and passing
- [x] Code reviewed
