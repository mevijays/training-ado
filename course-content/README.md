# AZ-400 Course Content — Designing and Implementing Microsoft DevOps Solutions

22 modules covering the April 2026 AZ-400 skills outline. Each follows: *Why this matters → Theory + analogies → Hands-on lab → Trainer notes → Next module*.

---

## Module index

### Process and communications

| # | Module | Topic |
|---|---|---|
| 1 | [DevOps Fundamentals](01-devops-fundamentals.md) | DevOps culture, principles, CALMS |
| 2 | [Azure DevOps Overview](02-azure-devops-overview.md) | Boards, Repos, Pipelines, Test Plans, Artifacts |
| 3 | [Agile Planning with Azure Boards](03-agile-boards.md) | Scrum / Kanban, work items, queries |

### Source control

| # | Module | Topic |
|---|---|---|
| 4 | [Git Version Control](04-git-version-control.md) | Core git, commits, branches, merges |
| 5 | [Branching Strategies](05-branching-strategies.md) | Trunk-based, GitFlow, release flow |
| 6 | [Azure Repos](06-azure-repos.md) | Branch policies, PR templates, security |

### Continuous Integration (heavy weight: 20-25%)

| # | Module | Topic |
|---|---|---|
| 7 | [Build Tools: Maven, npm, NuGet](07-build-tools-maven-npm-nuget.md) | Compilation, package management |
| 8 | [Azure Pipelines — CI Basics](08-azure-pipelines-ci.md) | Pipelines, jobs, steps, agents |
| 9 | [YAML Pipelines and Templates](09-pipelines-yaml-templates.md) | Syntax, parameters, templates, expressions |
| 10 | [Self-hosted Agents](10-self-hosted-agents.md) | Why, when, how to deploy |
| 11 | [Docker and Containers](11-docker-containers.md) | Images, multi-stage builds, Compose |
| 12 | [Container Registries (ACR)](12-container-registries.md) | Push/pull, geo-replication, tasks |

### Continuous Delivery

| # | Module | Topic |
|---|---|---|
| 13 | [CD and Deployment Strategies](13-cd-deployment-strategies.md) | Blue/green, canary, rolling, ring |
| 14 | [Deploying to AKS](14-aks-deployment.md) | kubectl, Helm, manifests via pipelines |
| 15 | [IaC with Pipelines](15-iac-with-pipelines.md) | Terraform/Bicep in pipelines, state, OIDC |
| 16 | [Azure Artifacts](16-azure-artifacts.md) | Feeds, upstream sources, retention |

### Security and Compliance

| # | Module | Topic |
|---|---|---|
| 17 | [Security and Compliance](17-security-compliance.md) | SAST/DAST/SCA, GHAS, supply chain |
| 18 | [Secrets and Azure Key Vault](18-secrets-keyvault.md) | Variable groups, Key Vault linking, OIDC |

### Instrumentation and SRE

| # | Module | Topic |
|---|---|---|
| 19 | [Monitoring and Instrumentation](19-monitoring-instrumentation.md) | App Insights, Log Analytics, distributed tracing |
| 20 | [SRE Strategy](20-sre-strategy.md) | SLI/SLO/SLA, error budgets, on-call |

### Cross-cutting

| # | Module | Topic |
|---|---|---|
| 21 | [GitHub Actions](21-github-actions.md) | Workflows, secrets, OIDC, reusable workflows |
| 22 | [Feature Flags](22-feature-flags.md) | Azure App Configuration, progressive rollout |

### Wrap-up

| # | Module | Topic |
|---|---|---|
| - | [Exam Preparation](exam-prep.md) | AZ-400 strategy and resources |

---

## Lab prerequisites checklist

- [ ] Azure DevOps org + project created
- [ ] GitHub account + a personal repo for labs
- [ ] Azure free account + an Azure DevOps service connection to it
- [ ] Local tools: `git`, Docker Desktop, Node 20, Java 17, Maven, .NET 8 SDK, Azure CLI, kubectl
- [ ] VS Code + extensions: Azure Pipelines, GitHub Pull Requests, Docker

---

## Navigation

- ⬅ [Repo README](../README.md)
- ➡ [Start: Module 1 — DevOps Fundamentals](01-devops-fundamentals.md)
- 🎯 [Capstone project](../project/README.md)
- 🤖 [GenAI for DevOps engineers](../genai/README.md)
