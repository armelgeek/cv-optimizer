# CV Optimizer 2.0 🚀

**Le compagnon de recherche d'emploi qui ne te piège pas dans un abonnement.**

Une plateforme SaaS complète pour découvrir des offres d'emploi, adapter ton CV pour chacune, te préparer aux entretiens, et suivre tes candidatures — le tout avec un système de crédit transparent et sans engagement.

---

## 🎯 Vision

Transformer CV Optimizer d'un outil "one-shot" (optimiser un CV) en une **plateforme compagnon de recherche d'emploi** complète où tu :

1. **Découvres** des offres pertinentes avec score de compatibilité automatique
2. **Optimises** ton CV pour chaque offre + reçois questions d'entretien
3. **Suis** tes candidatures en un seul endroit
4. **Te prépares** avec feedback d'analyse CV

Tout cela sans t'enfermer dans un abonnement auto-renouvelé.

---

## ⚡ Quick Start

### 1. Pré-requis
- Node.js 18+ 
- pnpm 11+
- PostgreSQL (via Neon, local, ou autre)
- ANTHROPIC_API_KEY (Claude API)
- SERPAPI_KEY (Google Jobs)

### 2. Setup
```bash
# Clone & install
git clone https://github.com/armelgeek/cv-optimizer.git
cd cv-optimizer
pnpm install

# Configure env
nano .env.local
# Ajoute: DATABASE_URL, ANTHROPIC_API_KEY, SERPAPI_KEY

# Initialise DB
pnpm db:push

# Start dev servers (ports 3000/3001/3002)
pnpm dev
```

### 3. Visite
- **App**: http://localhost:3000 (authenticated)
- **Web**: http://localhost:3001 (marketing)
- **API**: http://localhost:3002 (internal endpoints)

---

## 🏗️ Architecture

### Stack Technique
| Layer | Tech |
|-------|------|
| **Frontend** | Next.js 16, React 19, TypeScript, Tailwind CSS 4, Shadcn v2 |
| **Backend** | NestJS API, Server Actions, Next.js API routes |
| **Database** | PostgreSQL (Neon), Drizzle ORM |
| **Auth** | BetterAuth (sessions, OAuth) |
| **AI** | Claude API (Haiku/Sonnet for scoring & generation) |
| **Jobs API** | SerpAPI (Google Jobs) with cache abstraction |
| **Payments** | Stripe (one-time credits, no subscriptions) |
| **Hosting** | Vercel (Edge + Node runtime) |
| **Analytics** | PostHog |

### 4 Pages Principales

**1. Offres pour moi** (`/offers`)
- Découverte d'offres via SerpAPI
- Filters: titre, localisation, type contrat
- Score de compatibilité (0-100%) par offre
- Clic "Optimiser" → redirige vers optimizer avec offre pré-remplie

**2. Optimizer** (`/optimizer`, `/optimizer/[jobId]`)
- Upload CV (PDF) ou réutilisation du dernier
- Collage offre ou pré-remplie depuis discovery
- Génération parallèle Claude:
  - CV optimisé (tailorisé pour l'offre)
  - Score + explications (forces/lacunes)
  - 5 questions d'entretien + réponses suggérées
- "Sauvegarder & Télécharger" → sauvegarde en DB + PDF download

**3. Mes Applications** (`/applications`)
- Tableau de toutes tes candidatures
- Colonnes: Titre, Entreprise, Date, Statut, Score
- Click row → modal avec détails complets
- Sélecteur de statut (Candidaté/Entretien/Refusé/Offre/Archivé)
- Générateur de relance email (template copiable)

**4. Analyse CV** (`/cv-analysis`)
- Upload CV → feedback structuré (structure, ATS, keywords, gaps)
- Gratuit 1x/semaine
- Export PDF = 1 crédit

---

## 💰 Modèle Économique

### Palier Gratuit (Reset mensuel)
| Feature | Quota |
|---------|-------|
| Optimisations CV | 1/mois |
| Découverte offres | Illimitée |
| Score de match | Illimité (caché) |
| Analyse CV | 1x/semaine |
| Export PDF analyse | Payant (1 crédit) |
| Relances email | 3/mois |

### Crédits Payants (Sans abonnement)
- **10 crédits**: €6.99
- **30 crédits**: €14.99 (recommandé)
- **60 crédits**: €24.99

**1 crédit = 1 action payante** (optimisation CV, export PDF)

### 5 Moments d'Upsell
1. Après première optimisation
2. Palier gratuit épuisé
3. Visionnage de 5+ offres
4. 8+ candidatures enregistrées
5. Bonus premier achat (10 achetés → 12 offerts)

---

## 📊 Modèle de Données

### Principales Tables

**discovered_jobs** - Offres provenant de SerpAPI
```
id (UUID) | google_job_id | title | company | location | salary_min/max
job_type (CDI/Stage/Contract/Freelance) | job_posting_text | url | expires_at
```

**applications** - Candidatures sauvegardées
```
id | user_id | discovered_job_id | job_title | company | job_posting_text
optimized_cv | cv_match_score (0-100) | interview_questions (jsonb)
status (applied/interviewing/rejected/offer/archived) | created_at | updated_at
```

**cv_analyses** - Retours d'analyse CV
```
id | user_id | uploaded_cv | feedback | created_at
```

**job_search_cache** - Cache mutualisé (6-12h TTL)
```
id | query_hash (SHA256 de titre+localisation) | serpapi_response | expires_at
```

**users** (modifications)
```
free_uses_this_month (default 1) | free_uses_reset_date | last_cv_analysis_date
follow_up_emails_this_month (default 0) | credits_balance
```

---

## 🔄 Workflow Développement

### Commandes Principales
```bash
# Dev
pnpm dev              # Start all servers

# Database
pnpm db:generate      # Create migration
pnpm db:push          # Apply migrations
pnpm db:studio        # Open Drizzle Studio

# Quality
pnpm check            # Lint + typecheck
pnpm test             # Run tests
pnpm build            # Build all

# Ship
/ship-feature "..."   # Deliver feature (merge + deploy)
/standup              # Daily status update
```

### Git Flow
```
feat/task-name → PR → Code Review → /ship-feature → Deploy
```

---

## 🎓 Tech Decisions

### Pourquoi SerpAPI ?
- Légal (pas de scraping)
- Fiable API pour Google Jobs
- Cache mutualisé → coût maîtrisé

**Risque:** Litige DMCA en cours (Google vs SerpAPI)  
**Mitigation:** Abstraction provider-agnostic dès le départ; fallback vers Adzuna/Jooble possible

### Pourquoi pas d'auto-apply ?
- Risque spam/détection
- Recruteurs rejettent CV "IA génériques"
- **Positionnement:** Qualité > Quantité

### Pourquoi crédits, pas abonnement ?
- **Confiance:** Pas de facturation surprise
- **Concurrence:** Incumbents (MonCVParfait, CVcrea) souffrent d'abus d'abonnement
- **Achats impulsifs:** Recherche d'emploi = moments d'urgence → prêt à payer

### Claude (pas GPT) ?
- API stable + pricing prévisible
- Structured output (JSON parsing fiable)
- Haiku efficace pour scoring déterministe

---

## 📈 Roadmap

### Phase 1 (Semaine 1) ✅ MVP
- [x] 4 pages UI
- [x] Système crédits
- [x] Intégrations Claude + SerpAPI
- [x] Stripe checkout

### Phase 2 (Semaine 2-3)
- [ ] Email notifications pour offres matching
- [ ] Filtres avancés (slider salaire, multi-select)
- [ ] Auto-relances email (optionnel)
- [ ] Export candidatures (CSV)

### Phase 3+ (Post-MVP)
- [ ] Conseils négociation salariale
- [ ] Intégration LinkedIn
- [ ] Mobile app native
- [ ] Internationalization (EN, ES, DE)
- [ ] Analyse sentiments recruteurs

---

## 🔐 Sécurité

- **Auth:** BetterAuth sessions (stateless JWT)
- **RGPD:** Politique confidentialité + droit à l'oubli
- **Data:** CVs chiffrés au repos (encryption en DB)
- **Rate-limit:** @repo/rate-limit sur endpoints publics
- **Input:** Zod validation sur tous les Server Actions

---

## 📝 Contributing

Le projet est open-source. Pour contribuer :

1. Fork & crée une branche `feat/your-feature`
2. Fais tes changements
3. `pnpm check` + `pnpm test`
4. Crée une PR avec description claire
5. Code review + merge

**Règles:**
- Pas de symlinks (copies locales uniquement)
- TypeScript strict mode
- Tests pour logique métier
- Pas de dépendances non-essentielles

---

## 🚀 Deployment

### Vercel (Recommandé)
```bash
# Automatic from GitHub
# 1. Link repo on vercel.com
# 2. Set env vars (DATABASE_URL, ANTHROPIC_API_KEY, etc.)
# 3. Push to master → auto-deploy

# Migrations auto-run pré-deploy (cf. build script)
```

### Variables d'env (Production)
```env
DATABASE_URL=postgresql://...neon.tech/cv_optimizer?sslmode=require
ANTHROPIC_API_KEY=sk-ant-...
SERPAPI_KEY=...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
CRON_SECRET=your-secret-key
BETTER_AUTH_SECRET=min-32-chars-random
```

---

## 📊 Métriques de Succès

- **Conversion:** % gratuit → payant (cible 10%+)
- **Engagement:** Retour hebdomadaire sur Offres (cible 30%+)
- **Utilisation:** Quota gratuit consommé (cible 80%+)
- **Rétention:** Day-7 active users (cible 40%+)
- **Coût:** SerpAPI/utilisateur gratuit ≤ €0.50

---

## 📄 License

MIT – Libre d'utilisation, modification, distribution.

---

## 💬 Questions ?

- **Bugs:** Crée une GitHub Issue
- **Features:** Discussions → PRD → Feature
- **Security:** Email armelgeek5@gmail.com

---

**Bonne chance ! 🎯**

*"Le compagnon de recherche d'emploi qui ne te piège pas dans un abonnement."*
