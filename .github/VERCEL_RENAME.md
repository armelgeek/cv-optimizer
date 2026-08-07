# Renommer les projets Vercel pour URLs propres

Actuellement les URLs sont générées avec le nom du team ("armelgeeks-projects"). Pour avoir des URLs plus propres référencées au projet, renomme les projets.

## URLs Actuelles
```
web → web-armelgeeks-projects.vercel.app
app → app-armelgeeks-projects.vercel.app
api → api-armelgeeks-projects.vercel.app
```

## URLs Désirées
```
web → web-cv-optimizer.vercel.app
app → cv-optimizer.vercel.app
api → api-cv-optimizer.vercel.app
```

## Comment renommer

### Via Vercel Console (le plus simple)

1. **App Project** → https://vercel.com/armelgeeks-projects/app/settings
   - Scroll to "Project Name"
   - Changer "app" → "cv-optimizer"
   - Save

2. **Web Project** → https://vercel.com/armelgeeks-projects/web/settings
   - Scroll to "Project Name"
   - Changer "web" → "web-cv-optimizer"
   - Save

3. **API Project** → https://vercel.com/armelgeeks-projects/api/settings
   - Scroll to "Project Name"
   - Changer "api" → "api-cv-optimizer"
   - Save

### Après le renommage

Les URLs seront automatiquement mises à jour :
- `https://cv-optimizer.vercel.app` ✅
- `https://web-cv-optimizer.vercel.app` ✅
- `https://api-cv-optimizer.vercel.app` ✅

### Mettre à jour les env vars

Dans chaque projet Vercel, update les `NEXT_PUBLIC_*` URLs :

```
NEXT_PUBLIC_APP_URL=https://cv-optimizer.vercel.app
NEXT_PUBLIC_WEB_URL=https://web-cv-optimizer.vercel.app
NEXT_PUBLIC_API_URL=https://api-cv-optimizer.vercel.app
```

---

**Note:** Les Project IDs dans GitHub Secrets restent les mêmes, seules les URLs changent.
