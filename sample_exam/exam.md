# AZ-400 — Sample Exam (60 Questions)

Read each question, pick your answer, then click **Answer** to reveal the explanation.

Target: **≥ 42 / 60 (70%)** before attempting the real exam.

---

## Processes and Communications (7 questions)

### Q1. Which DevOps practice most directly reduces "it works on my machine" issues?

A. Daily standups
B. Infrastructure as Code
C. Story-point estimation
D. Burndown charts

<details><summary>Answer</summary>

**Correct: B**

IaC means dev/stage/prod come from the same code. Standups and estimation are process tools but don't address environment drift directly.
</details>

---

### Q2. DORA's four key metrics include all EXCEPT:

A. Deployment frequency
B. Lead time for changes
C. Story points completed per sprint
D. Change failure rate

<details><summary>Answer</summary>

**Correct: C**

DORA: Deployment frequency, Lead time, Change failure rate, MTTR (plus Reliability in newer reports). Story points are an Agile metric, not a DORA metric.
</details>

---

### Q3. Which Azure Boards work-item type sits ABOVE a User Story in the default Agile process?

A. Task
B. Bug
C. Feature
D. Test Case

<details><summary>Answer</summary>

**Correct: C**

Agile hierarchy: Epic → Feature → User Story → Task / Bug.
</details>

---

### Q4. (Multi-select) Which are typical components of an Azure DevOps organization? (Choose three.)

A. Projects
B. Service connections
C. Variable groups
D. Resource Groups

<details><summary>Answer</summary>

**Correct: A, B, C**

Resource Groups are an Azure (cloud) concept, not Azure DevOps.
</details>

---

### Q5. To link a Git commit to an Azure Boards work item #42, include in the commit message:

A. `Fixes #42`
B. `AB#42`
C. `WI:42`
D. `[boards] 42`

<details><summary>Answer</summary>

**Correct: B**

`AB#42` is the syntax Azure Boards parses from commit messages and PR titles.
</details>

---

### Q6. The recommended cadence for Scrum sprints is typically:

A. 1 day
B. 1-4 weeks
C. 3 months
D. 1 year

<details><summary>Answer</summary>

**Correct: B**

Scrum sprints are 1-4 weeks; 2 weeks is most common.
</details>

---

### Q7. (True/False) The Azure Boards process template (Basic, Agile, Scrum, CMMI) is selected at project creation and easily switched later.

<details><summary>Answer</summary>

**Correct: False**

Selected at creation, but switching requires careful migration — work item types and fields differ across templates.
</details>

---

## Source Control Strategy (7 questions)

### Q8. Which branching strategy works best with continuous deployment, feature flags, and small batches?

A. GitFlow
B. Trunk-based development
C. Centralized SVN-style
D. Release Flow with weekly releases

<details><summary>Answer</summary>

**Correct: B**

Trunk-based dev pairs naturally with CD: small frequent merges to main, features dark behind flags, ship multiple times per day.
</details>

---

### Q9. To prevent direct pushes to `main` in Azure Repos, configure:

A. A Git hook on every dev's machine
B. Branch policy with "require pull request"
C. RBAC at the repository level
D. Disable the `main` branch

<details><summary>Answer</summary>

**Correct: B**

Branch policies enforce PR-driven changes server-side. Local hooks are bypassable; RBAC restricts who can write but doesn't enforce PR flow.
</details>

---

### Q10. (Multi-select) Which can be required by an Azure Repos branch policy? (Choose three.)

A. Minimum number of reviewers
B. Successful build validation
C. Linked work items
D. Commit message length

<details><summary>Answer</summary>

**Correct: A, B, C**

A, B, C are built-in policies. Commit message length is not enforced as a branch policy in Azure Repos.
</details>

---

### Q11. CODEOWNERS-style "automatic reviewers by path" in Azure Repos is configured in:

A. A CODEOWNERS file in the repo
B. The branch policies of the target branch
C. `azure-pipelines.yml`
D. Per-user notifications

<details><summary>Answer</summary>

**Correct: B**

Azure Repos uses branch policies → "Automatically include reviewers" with path filters. GitHub uses a CODEOWNERS file.
</details>

---

### Q12. To avoid storing large binaries in Git history, use:

A. Git submodules
B. Git LFS
C. Branch deletion
D. `.gitignore` with rebase

<details><summary>Answer</summary>

**Correct: B**

Git LFS (Large File Storage) keeps binary blobs in a separate store and points to them from Git.
</details>

---

### Q13. In Azure Repos, branch policies are configured on the:

A. Source branch
B. Target branch
C. Both, must match
D. Repository root

<details><summary>Answer</summary>

**Correct: B**

Policies live on the destination branch (the one being merged INTO).
</details>

---

### Q14. Which merge strategy keeps `main` history linear with one commit per PR?

A. Merge commit
B. Squash merge
C. Rebase merge
D. Cherry-pick

<details><summary>Answer</summary>

**Correct: B**

Squash merge condenses the PR's commits into one. Rebase merge keeps each commit but linearizes them.
</details>

---

## Continuous Integration (14 questions)

### Q15. (True/False) In Azure Pipelines, PR triggers must be defined in the YAML of the target branch, not the source branch.

<details><summary>Answer</summary>

**Correct: True**

This catches many engineers. Move the `pr:` config to `main` first; PR validations don't fire from feature-branch YAML.
</details>

---

### Q16. Which YAML expression evaluates at compile time (when YAML is parsed)?

A. `$(var)`
B. `${{ ... }}`
C. `$[ ... ]`
D. `%var%`

<details><summary>Answer</summary>

**Correct: B**

`${{ }}` is compile-time. `$()` is runtime variable substitution. `$[ ]` is a runtime expression.
</details>

---

### Q17. To use a saved plan file across stages, you should:

A. Save it as a pipeline variable
B. Publish it as a pipeline artifact and `download:` in the next stage
C. Email it to the next runner
D. Re-run plan

<details><summary>Answer</summary>

**Correct: B**

`PublishPipelineArtifact@1` + `download: current` is the cross-stage handoff pattern. Variables are too small for binary artifacts.
</details>

---

### Q18. Pipeline templates support all of the following template types EXCEPT:

A. Step templates
B. Job templates
C. Stage templates
D. Pool templates

<details><summary>Answer</summary>

**Correct: D**

Step, job, stage, and variable templates exist. There is no "pool template" type.
</details>

---

### Q19. To restrict an org to a pipeline template (e.g., for SAST scanning compliance), use:

A. Required reviewers
B. Pipeline policy → "Required template"
C. Service connection permissions
D. Branch policies

<details><summary>Answer</summary>

**Correct: B**

Project settings → Pipelines → Required pipeline template enforces `extends:` from a specific template.
</details>

---

### Q20. (Multi-select) Microsoft-hosted agents are best when: (Choose two.)

A. You need access to a private VNet for build dependencies
B. You don't want to maintain VMs
C. You need clean, isolated builds with no leaked state
D. You need GPUs

<details><summary>Answer</summary>

**Correct: B and C**

Microsoft-hosted = no maintenance, fresh-per-job. Private VNet access and GPUs typically need self-hosted agents.
</details>

---

### Q21. The recommended modern approach for autoscaling self-hosted agents in Azure is:

A. Manual VMs + cron scripts
B. Azure DevOps Scale Set agents backed by Azure VMSS
C. Functions
D. Container Instances

<details><summary>Answer</summary>

**Correct: B**

Scale Set agent pools automatically resize the underlying VMSS based on queued jobs.
</details>

---

### Q22. Which Docker layer ordering maximizes cache hits in a Node.js Dockerfile?

A. COPY all source first, then RUN npm ci
B. COPY package*.json, RUN npm ci, then COPY remaining source
C. RUN npm ci before any COPY
D. Use only one big RUN

<details><summary>Answer</summary>

**Correct: B**

Copying only the package files first lets `npm ci`'s layer cache survive source changes. The remaining COPY invalidates only the final layer.
</details>

---

### Q23. Best practice for tagging an image built in CI is:

A. Tag only `:latest`
B. Tag with the commit SHA, plus optionally a semantic-version tag
C. Tag with a random UUID
D. Don't tag — let the registry assign

<details><summary>Answer</summary>

**Correct: B**

Immutable tags (commit SHA) give traceability. `:latest` is fine as a *secondary* tag for dev, never for prod deploy.
</details>

---

### Q24. Which is the modern, recommended way for an Azure DevOps pipeline to authenticate to Azure?

A. Storing a Service Principal password as a secret variable
B. Service connection with Workload Identity Federation (OIDC)
C. Storing the user's AAD password in Key Vault
D. Hardcoded subscription keys in YAML

<details><summary>Answer</summary>

**Correct: B**

OIDC = no long-lived secret stored in Azure DevOps. Microsoft's recommendation for all new service connections.
</details>

---

### Q25. Which Azure Pipelines feature lets you require human approval before a stage runs?

A. Branch policies
B. Environment + approval check
C. Variable groups
D. Build validation

<details><summary>Answer</summary>

**Correct: B**

Define an environment in Pipelines → Environments → Approvals & checks. Deployment jobs target that environment.
</details>

---

### Q26. To cache npm dependencies between pipeline runs, use:

A. `Cache@2` task with a key based on package-lock.json
B. Pipeline variable persistence
C. Service connection caching
D. Az storage account upload/download

<details><summary>Answer</summary>

**Correct: A**

`Cache@2` with a `key` derived from the lockfile maximizes cache hit and invalidates on dep changes.
</details>

---

### Q27. (Multi-select) Which are valid stages-level constructs in Azure Pipelines YAML? (Choose three.)

A. `dependsOn`
B. `condition`
C. `pool`
D. `jobs`

<details><summary>Answer</summary>

**Correct: A, B, D**

`pool` is set on jobs, not stages. `dependsOn`, `condition`, and `jobs` are stage-level.
</details>

---

### Q28. Which container registry tier is required for geo-replication and private endpoints in ACR?

A. Basic
B. Standard
C. Premium
D. All tiers support it

<details><summary>Answer</summary>

**Correct: C**

Geo-replication, content trust, private endpoints, and repository-scoped tokens are Premium-only.
</details>

---

## Continuous Delivery / Release Management (8 questions)

### Q29. Which deployment strategy keeps a complete second environment idle until a switch?

A. Rolling
B. Blue/Green
C. Canary
D. Recreate

<details><summary>Answer</summary>

**Correct: B**

Blue/Green = two parallel environments. Switch traffic atomically; instant rollback.
</details>

---

### Q30. App Service deployment slot "swap" is essentially:

A. A copy of binaries
B. A metadata change that flips routing — near-instant
C. A re-deploy of code
D. A DNS update with 5-minute TTL

<details><summary>Answer</summary>

**Correct: B**

The compute doesn't move; only the slot's identity flips. Hence the instant rollback by swapping back.
</details>

---

### Q31. Canary deployment refers to:

A. Running tests in production
B. Sending a small percentage of traffic to a new version, ramping up over time
C. Deploying to one region only
D. Reverting to last known good

<details><summary>Answer</summary>

**Correct: B**

Canary = progressive traffic shift with monitoring; auto-rollback if metrics regress.
</details>

---

### Q32. (Multi-select) Which are valid Kubernetes deployment strategies? (Choose two.)

A. Recreate
B. RollingUpdate
C. BlueGreenAuto
D. RecreateRolling

<details><summary>Answer</summary>

**Correct: A and B**

Built-in: `Recreate` and `RollingUpdate`. For blue/green and canary in K8s you use Argo Rollouts or Flagger.
</details>

---

### Q33. The Bicep equivalent of `terraform plan` is:

A. `az deployment group validate`
B. `az deployment group what-if`
C. `az bicep preview`
D. `bicep test`

<details><summary>Answer</summary>

**Correct: B**

`what-if` shows the diff without applying. `validate` only checks syntactic/template validity.
</details>

---

### Q34. Which deployment mode in ARM/Bicep DELETES resources in the resource group that aren't in the template?

A. Incremental
B. Complete
C. Validate
D. Drift

<details><summary>Answer</summary>

**Correct: B**

Complete mode is destructive — use with care. Incremental (default) only adds/updates.
</details>

---

### Q35. To safely roll out a database schema change without breaking older app versions, use:

A. Recreate strategy
B. Expand/contract migrations (forward-compatible)
C. Drop and recreate tables
D. Apply schema before deploying app code

<details><summary>Answer</summary>

**Correct: B**

Expand → migrate data → app uses new schema → contract. Allows mixed-version app states during deploy/rollback.
</details>

---

### Q36. Which Azure Pipelines feature stores reusable variables across pipelines?

A. Pipeline-level variables
B. Variable groups (Library)
C. Environment variables
D. Service connection secrets

<details><summary>Answer</summary>

**Correct: B**

Library variable groups are shareable across pipelines and can be Key Vault-linked for secret hygiene.
</details>

---

## Security and Compliance (8 questions)

### Q37. Which Azure DevOps integration is the recommended way to consume Azure Key Vault secrets in a pipeline?

A. Hardcode in YAML
B. Library variable group linked to a Key Vault
C. SSH them in from a build agent
D. ARM template parameters

<details><summary>Answer</summary>

**Correct: B**

Linked variable groups pull secrets at job-run time and expose them as masked variables. Rotation in KV is invisible to pipelines.
</details>

---

### Q38. Which scan type analyzes source code for vulnerabilities before runtime?

A. SAST
B. DAST
C. SCA
D. RASP

<details><summary>Answer</summary>

**Correct: A**

SAST = Static Application Security Testing — reads code statically. DAST tests a running app. SCA inspects dependencies.
</details>

---

### Q39. Which scan type finds vulnerabilities in your open-source dependencies?

A. SAST
B. DAST
C. SCA
D. Penetration test

<details><summary>Answer</summary>

**Correct: C**

SCA = Software Composition Analysis (Dependabot, Snyk, etc.).
</details>

---

### Q40. Why is OIDC federation preferred over a Service Principal secret?

A. Faster authentication
B. No long-lived secret to rotate or leak
C. Cheaper
D. Works without Entra ID

<details><summary>Answer</summary>

**Correct: B**

OIDC issues short-lived tokens via federated trust. Nothing sensitive stored in Azure DevOps or GitHub.
</details>

---

### Q41. (Multi-select) Which are valid effects on a pipeline `secret` variable? (Choose two.)

A. Masked in logs
B. Not auto-exposed as environment variables to scripts
C. Encrypted in source YAML
D. Stored in plain text in the database

<details><summary>Answer</summary>

**Correct: A and B**

Secrets are masked + require explicit `env:` mapping in scripts. They're encrypted at rest in Azure DevOps.
</details>

---

### Q42. GitHub Advanced Security for Azure DevOps provides which capabilities? (Multi-select — choose three.)

A. Secret scanning
B. Code scanning (CodeQL)
C. Dependency scanning
D. Performance profiling

<details><summary>Answer</summary>

**Correct: A, B, C**

GHAS = secret + code + dependency scanning. Performance profiling is unrelated.
</details>

---

### Q43. (True/False) `gitleaks` or similar secret scanners catch ALL secrets in your repo.

<details><summary>Answer</summary>

**Correct: False**

Scanners catch *patterns* (AWS key prefixes, common formats). Random long tokens without a known pattern may slip through. Defense in depth is required.
</details>

---

### Q44. To produce a Software Bill of Materials for a container image, use:

A. `syft` or similar
B. `terraform sbom`
C. `az image sbom`
D. `kubectl bill`

<details><summary>Answer</summary>

**Correct: A**

Syft / Trivy / cdxgen generate SBOMs in CycloneDX or SPDX format. None of the others exist.
</details>

---

## Instrumentation Strategy (5 questions)

### Q45. The three pillars of observability are:

A. Metrics, logs, traces
B. CPU, memory, network
C. Alerts, dashboards, runbooks
D. Build, deploy, release

<details><summary>Answer</summary>

**Correct: A**

Metrics (numeric time series), logs (events), traces (request path across services).
</details>

---

### Q46. Application Insights auto-instruments which languages without code changes? (Multi-select — choose three.)

A. .NET
B. Java
C. Node.js
D. Assembly

<details><summary>Answer</summary>

**Correct: A, B, C**

Codeless auto-instrumentation is available for .NET, Java, Node, Python on App Service. Assembly does not have auto-instrumentation.
</details>

---

### Q47. Which task adds a release annotation to App Insights from a pipeline?

A. `ApplicationInsightsAnnotation@1`
B. `AppInsightsLog@1`
C. `MonitorAlert@1`
D. `AzureMonitor@1`

<details><summary>Answer</summary>

**Correct: A**

`ApplicationInsightsAnnotation@1` marks the deploy timestamp on App Insights charts.
</details>

---

### Q48. (True/False) Workspace-based Application Insights stores its data in a Log Analytics workspace, not a separate datastore.

<details><summary>Answer</summary>

**Correct: True**

Workspace-based AppI (the modern default) writes to a LAW, unifying queries across the two.
</details>

---

### Q49. To correlate logs across services in a distributed request, the most important thing to include in every log line is:

A. Local timestamp
B. The trace_id / correlation_id
C. The pod name
D. The exception message

<details><summary>Answer</summary>

**Correct: B**

Without a shared trace ID, joining logs across services becomes manual archaeology.
</details>

---

## SRE Strategy (5 questions)

### Q50. The difference between SLA, SLO, and SLI:

A. They're synonyms
B. SLI is the measurement, SLO is the internal target, SLA is the external promise
C. SLA is the measurement, SLO is the average, SLI is the dashboard
D. SLA is daily, SLO is monthly, SLI is yearly

<details><summary>Answer</summary>

**Correct: B**

SLI → measured indicator. SLO → internal target on the indicator. SLA → contractual promise (usually looser than the SLO).
</details>

---

### Q51. If your SLO is 99.9%, your monthly error budget is approximately:

A. 1 second
B. 43 minutes
C. 4 hours 22 minutes
D. 7 hours

<details><summary>Answer</summary>

**Correct: B**

0.1% of ~30 days ≈ 43.2 minutes per month.
</details>

---

### Q52. What's the SRE response to consistently meeting 100% uptime when your SLO is 99.9%?

A. Celebrate and continue
B. Tighten the SLO to 99.99%
C. Take more risks — ship features faster
D. Reduce monitoring

<details><summary>Answer</summary>

**Correct: C**

Unused error budget = headroom for risk. The SRE answer is to ship faster (or to introduce chaos engineering) to use the budget productively.
</details>

---

### Q53. (Multi-select) Good characteristics of an SRE alert: (Choose three.)

A. Actionable
B. Page only what's worth waking someone for
C. Includes a runbook link
D. Fires on every blip

<details><summary>Answer</summary>

**Correct: A, B, C**

Alerting on every blip causes alert fatigue and lowers signal-to-noise.
</details>

---

### Q54. (True/False) A blameless postmortem assigns responsibility to the engineer who pushed the bad change.

<details><summary>Answer</summary>

**Correct: False**

Blameless means systems are responsible. "X pushed the button, but the system let them" — fix the system.
</details>

---

## GitHub Actions + Feature Flags (6 questions)

### Q55. The GitHub Actions equivalent of `task: AzureCLI@2` is:

A. `uses: azure/login@v2` + `run: az ...`
B. `task: AzureCLI@2` (same)
C. `gh az`
D. `script: az ...`

<details><summary>Answer</summary>

**Correct: A**

Auth happens once via `azure/login@v2`; subsequent `run:` steps call `az` against the authenticated session.
</details>

---

### Q56. For OIDC from GitHub Actions to Azure, the workflow must include:

A. `permissions: { id-token: write }`
B. A long-lived secret
C. `runs-on: self-hosted`
D. Nothing extra

<details><summary>Answer</summary>

**Correct: A**

Without that permission, GitHub Actions cannot mint the OIDC token. Without that token, the federated trust handshake fails.
</details>

---

### Q57. Reusable workflows in GitHub Actions are invoked with:

A. `uses: owner/repo/.github/workflows/x.yml@ref`
B. `template: x.yml`
C. `extends: x.yml`
D. `import x.yml`

<details><summary>Answer</summary>

**Correct: A**

`workflow_call` reusable workflows are called with `uses: owner/repo/.github/workflows/file.yml@ref` (must include `.github/workflows/` path).
</details>

---

### Q58. Feature flags are MOST useful for:

A. Reducing image size
B. Decoupling deployment from release
C. Compiling code faster
D. Replacing version control

<details><summary>Answer</summary>

**Correct: B**

Flags let you deploy code dark, then enable for some/all users without redeploying.
</details>

---

### Q59. (Multi-select) Valid filter types in Azure App Configuration feature management: (Choose two.)

A. Microsoft.Percentage
B. Microsoft.TimeWindow
C. Microsoft.RandomUser
D. Microsoft.CommitSha

<details><summary>Answer</summary>

**Correct: A and B**

Built-in filters: Percentage, TimeWindow, Targeting (groups/users). C and D are not built-in.
</details>

---

### Q60. (True/False) Old feature flags should be left in place forever in case rollback is needed.

<details><summary>Answer</summary>

**Correct: False**

Stale flags = dead code branches that complicate reasoning and accumulate maintenance debt. Delete release/experiment flags after they're 100% rolled out and stable for 2+ weeks.
</details>

---

## Score yourself

| Score | Verdict |
|---|---|
| 54-60 (90%+) | Strong — book the exam |
| 42-53 (70-89%) | Likely to pass — review weak topics, especially CI |
| 35-41 (60-69%) | More study needed; focus on CI/CD modules |
| < 35 | Work through course modules 7-22 again |

## Navigation

- ⬅ [Sample exam index](README.md)
- ⬅ [Course content](../course-content/README.md)
- ⬅ [Exam prep guide](../course-content/exam-prep.md)
- 🎯 [Capstone project](../project/README.md)
