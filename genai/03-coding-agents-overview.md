# 3 — Coding Agents Overview

A landscape tour of AI coding tools for DevOps engineers in 2026.

## What's an agent?

A **coding/admin agent** is an LLM-driven assistant that can read, write, and run code on your behalf. Compared to a plain chat box, an agent has:

- File-system access (read/write your repo).
- A shell or tool API (run commands, query systems).
- A loop that lets it work for many steps without each step needing input.

That last point — the loop — is what separates **agents** from **autocomplete**.

## The main tools, side by side

### GitHub Copilot

**Vendor:** GitHub (Microsoft) — multiple model backends.

**Form factor:** IDE plugins (VS Code, JetBrains, Vim), chat panel, code review on PRs, Copilot Workspace for multi-file planning, Copilot in the CLI.

**Strengths for DevOps:**
- Excellent autocomplete for YAML pipelines, Dockerfiles, K8s manifests.
- Reviews PRs natively on GitHub — including .github/workflows changes.
- Copilot for CLI suggests `az`, `kubectl`, `terraform`, `docker` commands.
- Enterprise edition: your code stays out of training.
- Copilot Workspace can refactor across files.

### Microsoft Copilot in Azure / Azure DevOps

**Vendor:** Microsoft.

**Form factor:** Built into the Azure portal and Azure DevOps UI.

**Strengths:**
- "Why did this pipeline fail?" — reads logs, gives plain-English answer.
- "Draft a KQL alert for failed deploys" — produces working KQL.
- "What changed in prod in the last 24 hours?" — correlates activity log + Boards work items.
- "Migrate this classic pipeline to YAML" — drafts the YAML.

### Claude Code

**Vendor:** Anthropic.

**Form factor:** CLI in your terminal, plus IDE plugins and a web version on claude.ai/code.

**Strengths:**
- Strong on long-context, multi-file edits.
- Agent-first: plans, edits, runs commands, iterates.
- First-class **skills**, **MCP servers** (custom tool plugins), **hooks**, **sub-agents**.
- Works directly on your repo, in your terminal.

**For DevOps:** great at refactoring shared pipeline templates, migrating between CI systems, complex infra refactors.

### Cursor

**Vendor:** Anysphere.

**Form factor:** A fork of VS Code.

**Strengths:**
- Inline chat (Cmd-K) for fast targeted edits.
- Composer for multi-file changes.
- Cursor Rules encode team conventions.

### Google Antigravity

**Vendor:** Google.

**Form factor:** Development environment built around Gemini.

**Strengths:**
- Massive context (Gemini's 1-2M tokens).
- Strong on cross-cutting analysis in large repos.
- Tight GCP integration (less Azure-specific).

### Windsurf, Aider, Continue.dev

Other entries in the space — same agent loop, different UX.

## Quick chooser

| If you want… | Pick |
|---|---|
| Inline completion in IDE | GitHub Copilot |
| Azure portal / AzDO Q&A | Microsoft Copilot in Azure |
| Agent in your terminal | Claude Code |
| Agent in your IDE | Cursor |
| Massive codebase analysis | Google Antigravity |
| Open-source / self-hosted | Aider |

Most teams use **two**: one for inline completion, one for autonomous edits.

## How an agent helps a DevOps engineer

1. **"Convert this Jenkinsfile to an azure-pipelines.yml using our templates."** Agent reads both, drafts the YAML, references your shared template repo.
2. **"This pipeline run failed in step 4. Why?"** Agent reads the log, identifies the root cause, suggests the fix.
3. **"Refactor all our pipelines to use the new `templates/v2/` versions instead of v1."** Multi-file PR.
4. **"Set up GitHub Actions OIDC to Azure for this repo."** Agent walks the App registration, federated credential, repo secret steps.
5. **"Write a KQL alert for failed deploys to prod from the deployment markers."** Working query, ready to paste.
6. **"Draft the postmortem from these incident chat logs."** Plain-English postmortem, ready to refine.

## What agents are bad at (still)

- Knowing what's secret. Always review what gets pasted.
- Knowing your team's preferences without being told. Use rules files / `AGENTS.md`.
- Knowing whether an operation is destructive. Always confirm.
- Predicting quotas / region availability without checking — verify.

## Setting up agents for DevOps repo success

A few files that drastically improve agent usefulness:

1. **`AGENTS.md`** or **`CLAUDE.md`** at repo root: pipeline conventions, secret locations, deploy environment names, on-call expectations, "don't run destructive commands without confirmation."
2. **Pipeline templates** in a single repo — agents pick up patterns.
3. **`README.md`** in every pipeline / IaC module.
4. **Pre-commit hooks** running formatters and linters — agents will adjust to satisfy them.
5. **Runbooks** in `docs/runbooks/` — agents read these during incidents.

## What's next (2026-2027)

- **Autonomous PR fixers** — open a PR, an agent fixes lint / writes tests / updates docs / asks for human review.
- **Cloud-resident SRE agents** — pages on alert, runs first-line triage, escalates with context.
- **Voice/chatops** — "Hey Copilot, what changed in prod yesterday?"

## Navigation

- ⬅ [Module 2 — LLMs Explained](02-llms-explained.md)
- ➡ [Module 4 — GenAI in DevOps Workflows](04-genai-in-devops.md)
