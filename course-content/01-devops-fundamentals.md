# Module 1 — DevOps Fundamentals

> **AZ-400 domain:** Design and implement processes and communications.

## Why this matters

DevOps is a culture first, tools second. The exam asks about cultural and process choices — pick a tool because it serves the culture, not the other way around.

## Theory

### What DevOps is

A combination of **practices**, **tools**, and **culture** that shortens the path from idea to running production software.

The CALMS framework:

| Letter | Pillar |
|---|---|
| **C**ulture | Shared ownership, blameless postmortems |
| **A**utomation | If you do it twice, automate it |
| **L**ean | Small batches, fast feedback, less WIP |
| **M**easurement | Measure what matters (DORA metrics, MTTR, SLOs) |
| **S**haring | Knowledge, code, tools, on-call |

### Analogy: Formula 1 pit crew

- An F1 pit stop takes 2 seconds because everyone knows their role, the tools are pre-positioned, and they've rehearsed it 10,000 times.
- A clueless garage team takes 10 minutes for the same job, half-blames each other, and the driver loses the race.
- DevOps is making your software org a pit crew, not a clueless garage.

### Core DevOps practices

1. **Version control everything** — code, config, infra, docs.
2. **Continuous Integration (CI)** — merge & test small changes often.
3. **Continuous Delivery (CD)** — every change is deployable at any time.
4. **Infrastructure as Code (IaC)** — Terraform, Bicep, ARM.
5. **Configuration as Code** — Ansible, Chef, settings.json.
6. **Monitoring + observability** — metrics, logs, traces.
7. **Automated testing** — unit, integration, contract, e2e, performance.
8. **Trunk-based development with small batches** — short-lived branches.
9. **Blameless postmortems** — learn from incidents.
10. **Feature flags** — decouple deploy from release.

### DORA metrics

The DevOps Research and Assessment (DORA) group identified four metrics that correlate with high-performing teams:

| Metric | "Elite" target |
|---|---|
| **Deployment Frequency** | On demand (multiple per day) |
| **Lead Time for Changes** | Less than 1 hour |
| **Change Failure Rate** | 0-15% |
| **MTTR (Mean Time to Restore)** | Less than 1 hour |

Plus a fifth in newer reports: **Reliability** (uptime / SLO attainment).

### Common DevOps anti-patterns

| Anti-pattern | Smell |
|---|---|
| "DevOps team" sitting between Dev and Ops | Still a silo, just renamed |
| Manual deployment runbooks | Risky; doesn't scale |
| Long-lived feature branches | Big-bang merges, integration pain |
| Pre-prod environment that's nothing like prod | Bugs only appear in prod |
| Nobody owns the on-call rotation | Nights and weekends suffer |
| "We'll test in prod with feature flags" without any tests | Wrong use of flags |

### Microsoft's DevOps perspective

Microsoft (and AZ-400) emphasizes:

- **Azure DevOps + GitHub** as two halves of one toolkit.
- **Shift-left security** — find issues at PR time, not after deploy.
- **Compliance-as-code** — policies enforced in pipelines.
- **Cloud-native operations** — IaC, immutable infra, observability everywhere.

## Lab — Map your team's current state

**Goal:** apply DevOps thinking to your own team (or a fictional one).

1. Pick a real or made-up team. Estimate their current DORA metrics:
   - Deployment frequency
   - Lead time for changes
   - Change failure rate
   - MTTR
2. Identify three anti-patterns from above that they have.
3. For each, propose:
   - A tooling change.
   - A process change.
   - A cultural change.
4. (Optional) Read the Microsoft Cloud Adoption Framework's DevOps section and compare your suggestions: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/

This is a discussion lab — useful before touching any tool, because tools without a target metric are just shiny objects.

## Trainer notes

- Spend more time on this than students think you should. The exam asks "scenario: a team's deployment frequency is once a quarter; which practice would help most?" — they need to know.
- Discussion: "Is 'we use Azure DevOps' the same as 'we do DevOps'?" (No. Tools enable; they don't deliver.)
- War story: a real team that improved their deployment frequency from monthly to daily by adopting trunk-based dev — and nothing else.

## Next

➡ [Module 2 — Azure DevOps Overview](02-azure-devops-overview.md)
⬅ [Course index](README.md)
