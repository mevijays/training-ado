# Azure DevOps Training Curriculum — AZ-400

A complete, self-paced curriculum for the **Microsoft Certified: DevOps Engineer Expert** (exam **AZ-400**), aligned to the latest April 2026 skills outline. Heavy emphasis on CI/CD pipelines (50-55% of the exam), with full coverage of source control, security, instrumentation, SRE, and process.

Useful for both **students** preparing for AZ-400 and **trainers** running structured sessions. Every topic has theory with analogies and a hands-on lab.

---

## Quick links

| Resource | Link |
|---|---|
| Official Study Guide AZ-400 | https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-400 |
| Official AZ-400 Microsoft Learning labs | https://microsoftlearning.github.io/AZ400-DesigningandImplementingMicrosoftDevOpsSolutions/ |
| Exam sandbox | https://go.microsoft.com/fwlink/?linkid=2226877 |
| Course content (start here) | [course-content/README.md](course-content/README.md) |
| Capstone project | [project/README.md](project/README.md) |
| GenAI for DevOps engineers | [genai/README.md](genai/README.md) |

---

## Exam at a glance

| Field | Value |
|---|---|
| Code | AZ-400 |
| Format | MCQ + case studies (rarely labs now) |
| Duration | 120 min |
| Question count | 40-60 |
| Passing score | 700/1000 |
| Validity | 1 year + free renewal |
| Cost | $165 USD |
| Prerequisite (not required but expected) | AZ-104 or AZ-204 knowledge |

---

## AZ-400 — domains (April 2026 update)

| Domain | Weight | Modules |
|---|---|---|
| Design and implement processes and communications | 10-15% | [01](course-content/01-devops-fundamentals.md), [02](course-content/02-azure-devops-overview.md), [03](course-content/03-agile-boards.md) |
| Design and implement a source control strategy | 10-15% | [04](course-content/04-git-version-control.md), [05](course-content/05-branching-strategies.md), [06](course-content/06-azure-repos.md) |
| Define and implement continuous integration | 20-25% | [07](course-content/07-build-tools-maven-npm-nuget.md), [08](course-content/08-azure-pipelines-ci.md), [09](course-content/09-pipelines-yaml-templates.md), [10](course-content/10-self-hosted-agents.md), [11](course-content/11-docker-containers.md), [12](course-content/12-container-registries.md) |
| Define and implement a continuous delivery and release management strategy | 10-15% | [13](course-content/13-cd-deployment-strategies.md), [14](course-content/14-aks-deployment.md), [15](course-content/15-iac-with-pipelines.md), [16](course-content/16-azure-artifacts.md) |
| Develop a security and compliance plan | 10-15% | [17](course-content/17-security-compliance.md), [18](course-content/18-secrets-keyvault.md) |
| Develop an instrumentation strategy | 5-10% | [19](course-content/19-monitoring-instrumentation.md) |
| Develop a Site Reliability Engineering strategy | 5-10% | [20](course-content/20-sre-strategy.md) |
| GitHub Actions + Feature flags (cross-cutting topics) | included above | [21](course-content/21-github-actions.md), [22](course-content/22-feature-flags.md) |

> Note: CI/CD together makes up **50-55%** of the exam. Plan study time accordingly.

---

## How to use this repo

- **Brand new to DevOps?** Modules 1-3 set the stage. Then proceed in order.
- **Already a developer?** Skim 1-6; spend most time on 7-22 plus the project.
- **Trainer?** Each module is one ~60-90 min session.

Each module follows: *Why this matters* → *Theory + analogies* → *Lab* → *Trainer notes* → *Next module*.

---

## Prerequisites

- Free **Azure DevOps** account: https://dev.azure.com (parallel free for 5 users + 1800 free pipeline minutes/month)
- Free **GitHub** account
- Free **Azure** account (for deploy targets)
- Local tools: `git`, Docker Desktop, Node 20, Java 17, Maven, .NET 8 SDK, Azure CLI, kubectl
- VS Code with Azure DevOps + GitHub extensions

---

## Repository structure

```
training-ado/
├── README.md                ← you are here
├── course-content/          ← 22 modules + exam prep
├── project/                 ← capstone: end-to-end CI/CD for a real app
└── genai/                   ← GenAI in DevOps workflows
```

Working pipeline examples live in:
- `workflow-examples/` — Azure Pipelines YAML samples
- `terraform/` — Terraform configs for AKS, VM
- `bicep/`, `bicep-examples/` — Bicep templates

---

## License & contributions

MIT license. PRs welcome.
