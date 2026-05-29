# Module 2 — Azure DevOps Overview

> **AZ-400 domain:** Design and implement processes and communications.

## Why this matters

Azure DevOps has five services that you'll use daily. Knowing which lives where (and where Microsoft is pushing GitHub instead) is on the exam.

## Theory

### The five services

| Service | Use |
|---|---|
| **Azure Boards** | Work items, backlogs, sprints, Kanban |
| **Azure Repos** | Git (and TFVC, legacy) hosting |
| **Azure Pipelines** | CI/CD (build + release) |
| **Azure Test Plans** | Manual + exploratory testing |
| **Azure Artifacts** | Package management (NuGet, npm, Maven, Python) |

### Azure DevOps vs GitHub

Microsoft owns both. Strategy as of 2026:

- **GitHub** is the strategic future. New investment goes there (Actions, Advanced Security, Copilot, Codespaces).
- **Azure DevOps** continues for existing customers, especially enterprise ones with TFVC, strong Boards usage, or Azure-tight scenarios.

For new projects, Microsoft increasingly recommends **GitHub + Azure**. AZ-400 covers both — Module 21 dives deeper into GitHub Actions.

### Organizations, projects, teams

Hierarchy:

```
Azure DevOps account
└── Organization (one per company, typically)
    └── Project
        └── Team (subset of project)
```

A project is the granular unit — it has its own Boards, Repos, Pipelines, etc.

### Security model

| Object | Scope |
|---|---|
| **Project Collection Administrators** | Org level |
| **Project Administrators** | Project level |
| **Contributors** | Default writers |
| **Readers** | Read-only |
| **Service Connections** | Bridge AzDO ↔ external (Azure, AWS, GitHub) |
| **Variable Groups** | Reusable variables, optionally Key Vault-backed |
| **Secure Files** | Binary secrets (certificates, kubeconfig) |
| **Environments** | Deployment targets, with approvals/checks |

### Service connections

A service connection is how a pipeline talks to an external system. For Azure, two flavors:

| Type | Authentication |
|---|---|
| **Service Principal (manual or auto)** | Password / secret |
| **Workload Identity Federation (OIDC)** | Federated trust, no secrets |

**Use OIDC for new pipelines.** No secrets to rotate or leak.

### Parallel jobs and licensing

Azure Pipelines uses **parallel jobs** as the unit of capacity:

- **Microsoft-hosted** — 1 free for public projects, 1 free for private (with grant), then $40/parallel/month.
- **Self-hosted** — 1 free for public, 1 free for private, then $15/parallel/month.

Parallel = how many jobs can run at once. Doesn't limit total minutes (other than free-tier minute caps).

### Process templates (Boards)

Boards comes with three templates:

- **Basic** — Issues, Tasks, Epics.
- **Agile** — User Stories, Tasks, Bugs, Features, Epics.
- **Scrum** — Product Backlog Items, Tasks, Bugs.
- **CMMI** — formal requirements, change requests, audits.

Pick one at project creation; can't change later (without effort).

### Permissions: scope vs role

- **Group-based** assignments scale better than per-user.
- **Inherited** from project to team to repo to pipeline.

### Analogy

- Azure DevOps **organization** = a company.
- **Project** = a department.
- **Service connection** = a corporate credit card the project uses to pay external vendors.
- **Variable group** = a shared bulletin board of constants.
- **Environment** = a destination (dev, staging, prod) with its own gatekeepers.

## Lab — Set up your training org

**Goal:** create an Azure DevOps org and a project you'll use throughout the course.

1. Sign into https://dev.azure.com with a Microsoft account. Create an organization (e.g., `your-name-az400`).
2. Create a project: `bookstore` (used for the capstone). Choose:
   - Visibility: Private
   - Version control: Git
   - Process: Scrum (or Agile if you prefer)
3. Explore each service via the left nav:
   - **Boards** — already has Sprints/Backlog set up.
   - **Repos** — empty Git repo waiting.
   - **Pipelines** — "New pipeline" wizard.
   - **Test Plans** — needs Basic + Test Plans license.
   - **Artifacts** — create a feed.
4. **Security** — Project Settings → Permissions. See the default groups (Project Administrators, Contributors, Readers).
5. **Service connection** to Azure (you'll need it later):
   - Project Settings → Service connections → New service connection → Azure Resource Manager.
   - Use **Workload Identity Federation (automatic)** if available, else Service Principal automatic.
   - Scope: subscription level.
6. Verify by going to **Pipelines → New pipeline → Empty job** and adding a step:
   ```yaml
   steps:
     - task: AzureCLI@2
       inputs:
         azureSubscription: 'your-service-connection-name'
         scriptType: bash
         scriptLocation: inlineScript
         inlineScript: 'az account show'
   ```
   Save + Run. Should show your subscription info — confirms the connection works.
7. Create a **variable group**: Library → + Variable group → name `shared-vars` → add `env=dev`.
8. Create an **environment**: Pipelines → Environments → New → name `dev`.

## Trainer notes

- Spend time on **service connections + OIDC** — this is where students get stuck in real life.
- Discussion: "When does it make sense to start in GitHub instead?" — open-source, heavy Copilot usage, GHAS scanning, or anything new in 2026.
- Common exam trap: free parallel jobs require a manual grant request the first time for private projects.

## Next

➡ [Module 3 — Agile Planning with Azure Boards](03-agile-boards.md)
⬅ [Module 1 — DevOps Fundamentals](01-devops-fundamentals.md)
