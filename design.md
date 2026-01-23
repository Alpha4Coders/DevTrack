# DevTrack Design

## System Overview
DevTrack is a full-stack platform that connects learning activity, GitHub project work, and AI insights. It ships as a React/Vite web client, optional mobile shells (Expo, Flutter), and an Express API that fronts Firebase, GitHub, and Groq.

## High-Level Architecture
```
[Web (Vite/React)] --
                     \                                  ┌──────────────┐
[Mobile (Expo/Flutter)] --(HTTPS+JWT)--> [Express API] --| Clerk (Auth) |
                     /                                  └──────────────┘
[Service Worker/FCM]--                                   ┌──────────────┐
                                                        | Firebase      |
                                                        | - Firestore   |
                                                        | - FCM         |
                                                        └──────────────┘
                                                        ┌──────────────┐
                                                        | GitHub API   |
                                                        └──────────────┘
                                                        ┌──────────────┐
                                                        | Groq (Llama) |
                                                        └──────────────┘
```

## Data Flow
- Authenticated clients call the API with Clerk-issued JWTs; middleware verifies and maps to internal user IDs.
- CRUD routes persist learning logs and projects in Firestore; writes emit timestamps for audit and streak logic.
- GitHub sync endpoints fetch repo metadata, commits, and languages via Octokit; results are cached in Firestore and surfaced in the dashboard.
- AI routes assemble context (project stats, recent commits, learning tags) and call Groq; responses are stored as analysis snapshots per project.
- Notifications use FCM tokens collected from client/service worker; server issues targeted reminders.

## Client Design (Web)
- **Routing**: React Router v6; guarded routes for dashboard, learning, projects, chat, settings, system info; landing remains public.
- **State & Data**: Minimal global state; per-page fetch via hooks (`useNotifications`, `useHeartbeat`, cache context). Prefer SWR/React Query-style cache semantics (stale-while-revalidate) for responsive dashboards.
- **UI/UX**: Tailwind + motion libraries; components split by domain (dashboard, landing, layout, ui). Loading states and optimistic UI for CRUD actions where safe.
- **Notifications**: Service worker `firebase-messaging-sw.js` handles FCM background messages; in-app permission prompts gate token registration.

## Mobile Design
- **Expo app**: Mirrors web flows; uses same Clerk + API endpoints and FCM for push. Navigation via Expo Router `_layout.tsx`.
- **Flutter app**: Uses shared API contracts; maintained separately to avoid blocking web delivery. Keep DTOs aligned with API schemas.

## API Design (Express)
- Routes namespaced under `/api`: auth, logs, projects, github, gemini, notification.
- **Middleware**: Auth verification (Clerk JWT), rate limiting (general vs AI), CORS, Helmet, input validation, error normalization.
- **Controllers/Services**: Thin controllers delegate to services for business logic (streak calc, GitHub fetch, AI prompt building, notification dispatch).
- **Pagination & Filtering**: Logs and projects support pagination; logs filter by tag, date, mood; GitHub endpoints accept repo identifiers.
- **Error Model**: JSON envelope with `code`, `message`, and optional `details`; 429 for throttling, 503 for dependency outages.

## Data Model Snapshot
- **User**: id, clerkId, email, name, githubUsername, createdAt.
- **Log**: id, userId, date, startTime, endTime, description, tags[], mood, createdAt.
- **Project**: id, userId, name, githubUrl, languages[], progress (0-100), aiAnalysis (text/metadata), commits, createdAt.
- **NotificationToken**: id, userId, token, platform, enabled, createdAt.
- **AIAnalysis**: id, projectId, modelVersion, inputContext hash, outputText, createdAt.

## AI Integration
- Groq (Llama 3.3) for project analysis and chat.
- Prompt builder includes repo stats, commit summaries, and learning tags; redacts secrets before send.
- Safeguards: timeout, retry with backoff, and cached last-good response when API is unavailable.

## GitHub Integration
- PAT stored server-side; Octokit client with conditional ETags to reduce rate usage.
- Sync strategies: on-create fetch, manual re-analyze, and periodic background refresh (future).
- Error handling: detect rate limits, surface actionable UI messages, avoid blocking core CRUD.

## Notifications
- FCM tokens collected from clients; stored per device.
- Server pushes streak nudges, project status changes, and AI analysis completion.
- Respect user opt-out; token revocation on 401/410 responses from FCM.

## Security & Privacy
- Clerk JWT verification for all protected routes; per-route rate limits (general vs AI tiers).
- CORS restricted to known origins; Helmet headers; input validation against injection.
- Secrets via environment variables only; no secrets in client bundles.
- Audit fields on writes; log request IDs for traceability.

## Performance & Reliability
- Cache GitHub results in Firestore; memoize AI inputs to avoid duplicate calls.
- p95 target: 400ms for cached reads; graceful degradation with skeletons/loading states.
- Idempotent sync endpoints; retries with jitter for external calls.

## Deployment
- **Client**: Vite build → static hosting/CDN.
- **API**: Node 18+, process manager (PM2/Fly/Render); HTTPS termination; health endpoint.
- **Env Separation**: dev/stage/prod configs; feature flags for experimental AI prompts and notifications.

## Testing Strategy
- Unit tests for services (streak calc, GitHub parsing, AI prompt builder).
- Integration tests for API routes (auth guard, validation, rate limits).
- E2E smoke for critical flows: sign-in, add log, add project with GitHub fetch, run AI analysis.
- Contract tests to keep mobile/web clients aligned with API schemas.

## Risks & Mitigations
- **Rate limits**: use ETags, backoff, and cached responses.
- **External downtime**: circuit breakers and fallback UI states.
- **Data consistency**: server-side validation, timestamps, and idempotent writes.

## Future Enhancements
- Public portfolio sharing and PDF exports.
- Team workspaces, shared dashboards, and review workflows.
- Background jobs for scheduled syncs and report generation.
