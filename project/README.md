# Capstone Project — End-to-End CI/CD for the Bookstore App

## Goal

Build a complete, production-shaped CI/CD platform for a three-service application across two environments (dev, prod). By the end you'll have running pipelines that build, test, scan, deploy, and observe a real app on Azure.

## Scenario

You are the platform engineer for **"BlueLeaf Bookstore"** (the same fictional company as the Azure capstone, intentionally).

- Engineering ships changes every day, in small batches.
- Three services: a Java API (Spring Boot), a React frontend (Node), and a Python data ingestion worker.
- Target deploy platform: Azure (App Service for the frontend, AKS for the API + worker).
- The CTO wants:
  - Branch-protected `main`.
  - Plan-on-PR / apply-on-merge for infra.
  - Prod deploys require approval.
  - SAST, SCA, secret scanning, container scan on every PR.
  - Feature flags for the new search experience.
  - Dashboards and on-call alerts.
  - Everything in code; no portal-only changes.

## Repos involved

```
bookstore-api/         (Java Spring Boot)
bookstore-web/         (React + Node)
bookstore-worker/      (Python ingest)
bookstore-infra/       (Terraform or Bicep)
bookstore-templates/   (shared pipeline templates)
```

## Phases

### Phase 1 — Project + Boards (modules 1-3)

- Create an Azure DevOps project `bookstore`.
- Create an Epic, two Features, six User Stories.
- Set up sprints and a Kanban board.
- Wire GitHub commit linking via `AB#`.

### Phase 2 — Source control + policies (modules 4-6)

- Init the three repos in Azure Repos.
- Branch policies on `main`: 1 reviewer, build validation, work-item link, comment resolution required.
- Auto-reviewers by path (e.g. `/infra/*` → platform team).
- PR templates.

### Phase 3 — CI for each service (modules 7-9)

- For each repo, write `azure-pipelines.yml` that:
  - Builds the service.
  - Runs unit tests.
  - Publishes a build artifact.
- Extract the common build steps into a `bookstore-templates` repo.
- Use **extends template** in each service's pipeline.

### Phase 4 — Self-hosted agent (module 10)

- Set up a scale-set agent pool in Azure VMSS (or a Docker agent).
- Direct one of the pipelines to use it.

### Phase 5 — Containerization + ACR (modules 11-12)

- Add a multi-stage Dockerfile to each service.
- Create a Premium ACR with geo-replication.
- Pipelines build + push images, tagged with commit SHA + semver.
- Set up an ACR base-image-update task for one image.

### Phase 6 — IaC for infra (modules 14-15)

- In `bookstore-infra`, write Bicep (or Terraform) for:
  - Resource groups: `rg-bookstore-net`, `rg-bookstore-app`, `rg-bookstore-data`, `rg-bookstore-shared`.
  - VNet, AKS cluster, App Service plan, App Service for `web`, Postgres Flexible, Storage Account, Log Analytics, App Insights, Key Vault, ACR (in `rg-shared`).
- Pipeline: plan on PR (posts comment), apply on merge with environment approval.
- Use OIDC for the service connection.

### Phase 7 — CD for each service (modules 13-14)

- API + worker deploy to AKS via Helm.
- Frontend deploys to App Service slots (blue/green swap).
- Each pipeline has stages: Build → Dev → Prod with approval gate.

### Phase 8 — Security (modules 17-18)

- Add secret scanning (gitleaks task or GHAS) to every PR.
- Add SAST (CodeQL) to PRs.
- Add Trivy container scan to build pipelines.
- Add Checkov to the infra pipeline.
- Move all secrets to Key Vault; link variable groups.

### Phase 9 — Artifacts (module 16)

- Create an Azure Artifacts feed.
- The `bookstore-api` produces a Maven artifact published to the feed.
- The `bookstore-web` consumes a small private npm utility package from the feed.

### Phase 10 — Observability + SRE (modules 19-20)

- Connect each service to App Insights.
- Build a dashboard with: deploy markers, p95 latency, failure rate per service.
- Define one SLO per service.
- Create burn-rate alerts on each SLO.
- Document an on-call runbook in `bookstore-infra/docs/runbook.md`.

### Phase 11 — Feature flags (module 22)

- Stand up Azure App Configuration.
- Add a `newSearch` flag.
- Frontend respects the flag; toggleable from a pipeline.
- Demonstrate a progressive rollout 1% → 10% → 100%.

### Phase 12 — GitHub Actions variant (module 21)

- Pick one service (the frontend is a good choice). Build an alternative `.github/workflows/ci-cd.yml` that does the same CI/CD via GitHub Actions with OIDC to Azure.
- Compare the experience.

## Acceptance criteria

- [ ] All three services have green CI pipelines using shared templates.
- [ ] All three services have CD pipelines that deploy to dev automatically and prod with approval.
- [ ] Infra is in Bicep/Terraform, applied via pipeline with OIDC.
- [ ] No secrets in YAML or repo. All in Key Vault.
- [ ] Container images are scanned; PR fails on HIGH/CRITICAL CVEs.
- [ ] App Insights dashboards exist for each service.
- [ ] At least one SLO + burn-rate alert exists.
- [ ] Feature flag drives at least one user-visible behavior.
- [ ] Branch policies + auto-reviewers + PR templates configured.
- [ ] One GitHub Actions equivalent pipeline runs.

## Stretch goals

- Move to GitOps with Argo CD or Flux on the AKS cluster.
- Add Argo Rollouts for canary deploys of the API.
- Add Chaos Studio experiments to the prod cluster.
- Add Cost dashboards (infracost in PRs, Azure Cost Mgmt alerts).
- Add Defender for DevOps and address findings.
- Build a self-service catalog using Azure Deployment Environments.

## Navigation

- ⬅ [Course content](../course-content/README.md)
- ⬅ [Repo README](../README.md)
- 🤖 [GenAI for DevOps engineers](../genai/README.md)
