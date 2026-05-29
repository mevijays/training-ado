# Module 21 — GitHub Actions

> **AZ-400 domain:** Cross-cutting — GitHub Actions appears across multiple domains, especially CI and CD.

## Why this matters

Microsoft owns GitHub. New investment goes there. AZ-400 explicitly tests GitHub Actions alongside Azure Pipelines — sometimes asking which you'd choose.

## Theory

### Mental model — same idea, different YAML

GitHub Actions runs **workflows** in response to **events**. Workflows have **jobs**, jobs have **steps**, steps run actions or shell commands.

Compare:

| Azure Pipelines | GitHub Actions |
|---|---|
| `azure-pipelines.yml` | `.github/workflows/*.yml` |
| `trigger:` | `on:` |
| Stages → Jobs → Steps | Jobs → Steps |
| `task: Foo@1` | `uses: org/repo@vN` |
| `pool: { vmImage: ubuntu-latest }` | `runs-on: ubuntu-latest` |
| Variable group | Environment secrets / org secrets |
| Service connection | OIDC + GitHub repo/env secret |
| Environment + approvals | Environment + protection rules |

### Minimal workflow

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

Save as `.github/workflows/ci.yml`.

### Actions marketplace

`uses: actions/checkout@v4` pulls an action from the GitHub Marketplace. Pin to a SHA for max safety:

```yaml
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11   # v4.1.1
```

### Matrix builds

Build across versions/OS:

```yaml
strategy:
  matrix:
    node: [18, 20, 22]
    os: [ubuntu-latest, windows-latest]
runs-on: ${{ matrix.os }}
steps:
  - uses: actions/setup-node@v4
    with: { node-version: ${{ matrix.node }} }
```

### Secrets

- **Repository secrets** — per-repo.
- **Environment secrets** — per environment (with approvers).
- **Organization secrets** — shared across repos.

Use in workflow:

```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### OIDC to Azure

The 2026 best practice for CI → Azure. No secrets stored in GitHub.

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - run: az account show
```

Set up:
1. Create an Entra ID app or User Assigned MI.
2. Add a federated credential trusting GitHub Actions on a specific repo/branch.
3. Assign Azure RBAC roles.
4. Store the client/tenant/sub IDs as repo secrets — these are not sensitive on their own.

### Environments and approvals

```yaml
jobs:
  deploy:
    environment: production
    steps: [...]
```

Configure `production` in **Settings → Environments**: required reviewers, wait timer, branch restrictions.

### Reusable workflows

Define once, call from many repos:

```yaml
# .github/workflows/_build.yml
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'

jobs:
  build:
    runs-on: ubuntu-latest
    steps: [...]
```

Caller:

```yaml
jobs:
  call-build:
    uses: my-org/.github/.github/workflows/_build.yml@v1
    with:
      node-version: '22'
```

### Composite actions

Bundle several steps into one `uses:`. Stored as a directory with `action.yml`.

### Self-hosted runners

Same idea as AzDO self-hosted agents:

```yaml
runs-on: [self-hosted, linux, prod]
```

GitHub's modern recommendation: **ARC** (Actions Runner Controller) on Kubernetes for autoscaling runners.

### GitHub vs Azure Pipelines — when to pick which

| If you… | Pick |
|---|---|
| Already on GitHub | GitHub Actions |
| Need tight integration with Boards / Test Plans | Azure Pipelines |
| Want first-class Copilot / Advanced Security | GitHub |
| Multi-stage Azure-specific deploys | Either — Pipelines slightly more featured |
| Open source project | GitHub Actions (free unlimited) |

Microsoft's strategic direction is GitHub. Choose accordingly for new work.

### Analogy

- GitHub Actions = a younger, more pluggable cousin of Azure Pipelines. Same DNA, different surface.
- Marketplace = npm for CI steps.
- Reusable workflows = function libraries for CI/CD.

## Lab — Same pipeline, GitHub Actions edition

**Goal:** rewrite the Azure Pipelines bookstore CI/CD in GitHub Actions with OIDC.

1. Create a new GitHub repo `bookstore-actions`. Push the bookstore-api code.
2. Set up Azure OIDC trust:
   ```bash
   APP_ID=$(az ad app create --display-name "github-bookstore" --query appId -o tsv)
   az ad sp create --id $APP_ID
   az role assignment create --assignee $APP_ID --role Contributor \
     --scope $(az account show --query id -o tsv | sed 's|^|/subscriptions/|')
   az ad app federated-credential create --id $APP_ID --parameters @<(cat <<EOF
   {
     "name": "main-branch",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:<your-gh-user>/bookstore-actions:ref:refs/heads/main",
     "audiences": ["api://AzureADTokenExchange"]
   }
   EOF
   )
   ```
3. Set repo secrets in GitHub: `AZURE_CLIENT_ID` = $APP_ID, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
4. `.github/workflows/ci-cd.yml`:
   ```yaml
   name: CI/CD
   on:
     push: { branches: [main] }
     pull_request: { branches: [main] }

   permissions:
     id-token: write
     contents: read

   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with: { node-version: '20', cache: 'npm' }
         - run: npm ci
         - run: npm test
         - uses: docker/setup-buildx-action@v3
         - uses: docker/build-push-action@v6
           if: github.event_name == 'push'
           with:
             tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
             push: true
           env:
             # auth to GHCR via GITHUB_TOKEN
             GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

     deploy:
       needs: build
       if: github.ref == 'refs/heads/main'
       runs-on: ubuntu-latest
       environment: production
       steps:
         - uses: azure/login@v2
           with:
             client-id: ${{ secrets.AZURE_CLIENT_ID }}
             tenant-id: ${{ secrets.AZURE_TENANT_ID }}
             subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
         - run: az webapp config container set -g rg-prod -n bookstore-api \
             --docker-custom-image-name ghcr.io/${{ github.repository }}:${{ github.sha }}
   ```
5. Configure the `production` environment in repo settings with one required reviewer.
6. Open a PR; CI runs. Merge; deploy waits for approval; approve; deploys.

## Trainer notes

- Show the GitHub Actions UI logs side-by-side with an AzDO pipeline run. Same shape, friendlier UI.
- Discussion: "Why OIDC over a service principal secret?" — secret rotation, leak risk, auditability.
- Common exam trap: `permissions: { id-token: write }` is required for OIDC; missing it → 400 errors.

## Next

➡ [Module 22 — Feature Flags](22-feature-flags.md)
⬅ [Module 20 — SRE Strategy](20-sre-strategy.md)
