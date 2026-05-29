# Exam Preparation — AZ-400

The Azure DevOps Engineer Expert exam. Heavy on CI/CD (50-55% combined). Scenario-rich.

## Exam at a glance

| Field | Value |
|---|---|
| Code | AZ-400 |
| Format | MCQ + case studies |
| Duration | 120 minutes |
| Question count | 40-60 |
| Passing score | 700/1000 |
| Validity | 1 year, free renewal via Microsoft Learn |
| Price | $165 USD |
| Latest update | April 24, 2026 |

## Domain weighting (April 2026)

| Domain | Weight | Modules |
|---|---|---|
| Design and implement processes and communications | 10-15% | [01](01-devops-fundamentals.md), [02](02-azure-devops-overview.md), [03](03-agile-boards.md) |
| Design and implement source control | 10-15% | [04](04-git-version-control.md), [05](05-branching-strategies.md), [06](06-azure-repos.md) |
| Define and implement CI | 20-25% | [07](07-build-tools-maven-npm-nuget.md), [08](08-azure-pipelines-ci.md), [09](09-pipelines-yaml-templates.md), [10](10-self-hosted-agents.md), [11](11-docker-containers.md), [12](12-container-registries.md) |
| Define and implement CD and release management | 10-15% | [13](13-cd-deployment-strategies.md), [14](14-aks-deployment.md), [15](15-iac-with-pipelines.md), [16](16-azure-artifacts.md) |
| Security and compliance | 10-15% | [17](17-security-compliance.md), [18](18-secrets-keyvault.md) |
| Instrumentation strategy | 5-10% | [19](19-monitoring-instrumentation.md) |
| Site Reliability Engineering | 5-10% | [20](20-sre-strategy.md) |
| Cross-cutting | n/a | [21](21-github-actions.md), [22](22-feature-flags.md) |

## 6-week study plan

### Weeks 1-2 — Process + Source control

- Day 1-2: Modules 1, 2
- Day 3-4: Module 3 (Boards)
- Day 5-7: Modules 4-6 (Git, branching, Azure Repos)

### Weeks 3-4 — CI focus (largest weight)

- Day 8-9: Module 7 (build tools)
- Day 10-12: Modules 8, 9 (Pipelines + templates) — repeat labs twice
- Day 13: Module 10 (self-hosted agents)
- Day 14-15: Modules 11, 12 (Docker + ACR)

### Week 5 — CD + Security

- Day 16-17: Modules 13, 14 (deployment strategies, AKS)
- Day 18: Module 15 (IaC pipelines)
- Day 19: Module 16 (Azure Artifacts)
- Day 20-21: Modules 17, 18 (security + secrets)

### Week 6 — Instrument, SRE, cross-cutting

- Day 22-23: Modules 19, 20 (monitoring + SRE)
- Day 24: Module 21 (GitHub Actions)
- Day 25: Module 22 (feature flags)
- Day 26-28: [Capstone project](../project/README.md)
- Day 29-30: Practice tests; review weak topics
- Day 31: Sit AZ-400

## Things the exam *definitely* asks

- **YAML syntax** — `${{ }}` vs `$()` vs `$[ ]`.
- **Stages, jobs, deployment jobs**, environments.
- **PR triggers** living in the target branch.
- **Variable groups**, especially Key Vault-linked.
- **Service connections**, with bonus points for OIDC / Workload Identity Federation.
- **Self-hosted agents** — when and how.
- **Templates** — step, job, stage, extends; required templates.
- **Approvals and checks** on environments.
- **Branch policies** — required reviewers, build validation, work item linking.
- **Deployment strategies** — blue/green, canary, rolling, ring.
- **Slot swapping** in App Service.
- **Container registry** options, ACR Tasks.
- **Artifacts feeds + upstream sources**.
- **Secret scanning, SAST, SCA, IaC scan**.
- **App Insights** + release annotations + telemetry queries.
- **SLO + error budget concepts**.
- **GitHub Actions** OIDC to Azure.
- **Feature flags** with Azure App Configuration.

## Common trap questions

| Trap | Reality |
|---|---|
| "Service connections work everywhere they're defined." | Pipelines must be granted access; not project-wide by default. |
| "Pipeline runs on the agent that issues the trigger." | No — agents are pulled from the configured pool. |
| "PR triggers are set in the source branch's YAML." | No — they live in the target branch's YAML. |
| "AKS pulls from ACR using a Kubernetes secret." | Best practice is `az aks update --attach-acr` (identity-based). |
| "Variable groups expose all secrets to all pipelines." | Only after explicit "Allow" per pipeline (or "All pipelines"). |
| "Branch policies apply on the source branch." | No — they're configured on the destination branch. |
| "Blue/green requires duplicated compute." | App Service slots are blue/green *without* duplicated compute. |
| "AZ-400 is purely about Azure." | It tests GitHub Actions and broader DevOps practices too. |

## Practice resources

- Official Microsoft Learn path: https://learn.microsoft.com/training/courses/az-400t00
- Microsoft Practice Assessment (free): https://learn.microsoft.com/credentials/certifications/devops-engineer/practice/assessment
- MeasureUp practice tests (paid).
- Tutorials Dojo / Whizlabs.
- The official AZ-400 GitHub labs: https://microsoftlearning.github.io/AZ400-DesigningandImplementingMicrosoftDevOpsSolutions/

## Day-of-exam tips

- Read the **case studies** twice — they contain constraints you'd miss otherwise.
- "All that apply" usually means ≥ 2 answers; partial credit usually doesn't exist.
- Eliminate impossibilities first.
- Watch for **best vs minimum** wording — both can be correct; only one is the answer.
- Pace: ~100 sec/question average, more for case studies.

## After passing

- Microsoft DevOps Engineer Expert badge appears in your Microsoft Learn profile.
- Renewable for free yearly via a short Microsoft Learn assessment.
- Natural next certs: **AZ-305** (Solutions Architect), **GH-300** series (GitHub-specific), **SC-100** (Cybersecurity Architect Expert).

## Navigation

- ⬅ [Module 22 — Feature Flags](22-feature-flags.md)
- ⬅ [Course index](README.md)
- 🎯 [Capstone project](../project/README.md)
- 🤖 [GenAI for DevOps engineers](../genai/README.md)
