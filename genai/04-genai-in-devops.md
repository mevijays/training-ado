# 4 — GenAI in DevOps Workflows

How to use GenAI day-to-day in a DevOps role, with concrete examples.

## Use case 1 — Drafting pipelines

**Prompt to your agent:**

> Read our shared templates in `bookstore-templates/`. Notice the `steps-build-node.yml`, `steps-build-java.yml`, and `stages-deploy.yml` files. Create a new `azure-pipelines.yml` for a Python service that lives in `bookstore-worker/`. Build with `pip` + `pytest`, containerize, push to ACR, deploy to AKS following our template conventions.

The agent reads existing templates, infers conventions, drafts a consistent new pipeline. Review for:
- Correct image tag scheme.
- Right approval gates.
- Variable group usage.
- Trigger paths.

## Use case 2 — Migrating between CI systems

```
You: Convert this Jenkinsfile to an azure-pipelines.yml that uses our shared
     templates. Preserve all the test stages and the SonarQube integration.

Agent: Reads the Jenkinsfile + our templates, drafts the YAML, maps stages
       and credentials. Flags one Jenkins-specific feature (parameterized 
       triggers) that needs different handling in AzDO.
```

## Use case 3 — Diagnosing a failing build

A build fails in step 4 of stage 2. You're at lunch. Open Claude Code or Copilot Chat:

> The pipeline run at https://dev.azure.com/.../runs/12345 failed. Get the logs, identify why, and suggest the fix.

The agent fetches the logs (via PAT or CLI), grep'd through them, identifies "npm ci failed because lockfile drift on package-lock.json after merge conflict resolution," and proposes a fix.

## Use case 4 — Writing KQL

KQL is fiddly. Agents are great at it.

**Prompt:**

> Write a KQL query in App Insights that returns the p50, p95, and p99 latency 
> of HTTP requests to `/api/search` broken down by app version (use `application_Version`),
> for the last 24 hours. Render as a timechart.

```kusto
requests
| where timestamp > ago(24h)
| where url has "/api/search"
| summarize 
    p50 = percentile(duration, 50),
    p95 = percentile(duration, 95),
    p99 = percentile(duration, 99)
    by bin(timestamp, 5m), application_Version
| render timechart
```

Tweak, run, save as a workbook tile.

## Use case 5 — Reviewing your own PR

Before opening a PR:

> Read the diff in this branch. Identify: hardcoded values, missing tests, 
> obvious YAML mistakes, secrets I might have committed accidentally, and 
> deviations from our pipeline-templates conventions.

You get a checklist. Fix what's real. Spend less time in code review.

## Use case 6 — Generating Bicep/Terraform from intent

> Draft a Bicep module for a Premium ACR with geo-replication to West Europe, 
> private endpoint into VNet "vnet-prod" subnet "acr", and a base-image-update 
> task. Match the style of our other modules in `modules/`.

You get a starting point. Review:
- Correct API versions.
- Sane defaults.
- Right parameter shape.
- Naming convention.

## Use case 7 — Drafting a postmortem

After an incident, you have Slack scrollback, alert pages, PR diffs, and Boards work items.

> Read the incident comms in `incident-2026-04-22.md`, the pages in 
> `pages-04-22.txt`, and the deploy log around 14:30 UTC. Draft a blameless 
> postmortem with: timeline, impact, contributing factors, action items.

Format result, refine, share. Spend more time in the retro discussing, less time typing.

## Use case 8 — Writing tests for pipelines

`azure-pipelines.yml` files don't have unit tests in the classic sense, but you can:

> For each template in `bookstore-templates/`, draft a `templates/tests.yml` 
> pipeline that exercises the template with realistic parameters and asserts 
> the resulting jobs look right (use `expand` and a script to validate).

Same for Bicep — generate `bicep what-if` checks for known parameter combos.

## Use case 9 — Drafting runbooks

> Read `infra/aks/main.bicep`. Draft a runbook in `docs/runbooks/aks-node-pool-rotation.md` 
> that explains how to add a new node pool, drain the old one, and remove it.

Often the agent produces 80% of a good runbook. Edit, validate, ship.

## Setting up agents for DevOps repo success

A short checklist for your AzDO / GitHub repos:

1. **`AGENTS.md` / `CLAUDE.md`** at repo root with:
   - Pipeline conventions (variable groups, env names, template repo).
   - Deploy environment names.
   - Secret locations (KV name + variable group naming).
   - "Don't run `az resource delete`, `kubectl delete`, or `terraform destroy` without explicit human confirmation."
2. **Pipeline templates** in a shared repo — agents reproduce patterns.
3. **`README.md`** per module/pipeline with inputs and outputs.
4. **Pre-commit hooks** (yamllint, terraform fmt, etc.).
5. **Runbooks** in `docs/runbooks/`.

## What NOT to do

- **Don't blindly execute** agent-suggested destructive commands. Always review.
- **Don't paste production secrets** into a chat — even Copilot. Use KV references.
- **Don't let the agent deploy to prod** without a human gate.
- **Don't trust an agent's claim** about exact CLI syntax — verify with `--help` or docs.

## A worked example session

```
You: One of our pipelines is randomly failing on flake. Investigate.

Agent: Pulls last 30 runs of pipeline "bookstore-api-ci". 8 failed; all in 
       step "integration-tests". All failures show "Connection refused: 
       database not ready." Database starts via docker-compose in a previous 
       step. Compose service has no health check; tests run immediately.
       Recommendation: add a `healthcheck:` to the postgres service in 
       compose, and a `wait-for-it.sh` in the test step.

You: Make the change.

Agent: Drafts the docker-compose.yml + pipeline change, opens a PR.

You: (Review, approve, merge.) Flake disappears.
```

That's the loop.

## Navigation

- ⬅ [Module 3 — Coding Agents Overview](03-coding-agents-overview.md)
- ⬅ [GenAI index](README.md)
- 🎯 [Capstone project](../project/README.md)
- 📚 [Course content](../course-content/README.md)
