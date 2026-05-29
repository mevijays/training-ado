# Module 6 — Azure Repos

> **AZ-400 domain:** Design and implement a source control strategy.

## Why this matters

Azure Repos is one of two main place where AZ-400 source control content lives (GitHub is the other). The exam tests permissions, policies, PR mechanics, and how to migrate from TFVC.

## Theory

### What Azure Repos is

A Git host inside Azure DevOps. Features include:

- Unlimited private repos.
- Branch policies (Module 5).
- PRs with reviewers, comments, work item linking.
- Code search across the org.
- Git LFS support.
- Webhooks + service hooks.
- TFVC (Team Foundation Version Control) for legacy users — centralized, *don't pick this for new work*.

### Permissions

Permissions cascade: Project → Repository → Branch.

Common scenarios:

- **Lock down `main`** — only PR-driven changes.
- **Restrict creation** of new branches under a path.
- **Grant a specific group** read-only access to a sensitive repo.

### CODEOWNERS / required reviewers

In Azure Repos, **automatic reviewers** are configured per branch policy with path filters:

```
docs/* → @docs-team
infra/* → @platform
src/auth/* → @auth-leads, @security
```

GitHub uses a `CODEOWNERS` file in the repo. Azure Repos uses the UI.

### Git LFS (Large File Storage)

For storing binary files (.psd, .mp4, large data) outside the regular git blob store.

```bash
git lfs install
git lfs track "*.psd"
git add .gitattributes
```

### Multi-repo vs monorepo

| | Monorepo | Multi-repo |
|---|---|---|
| Repos | One | Many |
| Coordination | Easy (one PR for cross-cutting changes) | Hard (multiple PRs) |
| Tooling | Heavy (Nx, Bazel, Turborepo) | Lighter |
| Permissions | Coarse | Fine-grained |
| Scale | Up to millions of files with Sparse Checkout | Naturally scales |
| Build minutes | Targets-based (avoid building everything) | Per-repo |

Microsoft is famously monorepo (Office, Windows). Most teams pick smaller scope.

### Migrating from TFVC to Git

`git-tfs` can import history. Practical approach:

1. Clone TFVC history with `git-tfs` to a temp Git repo.
2. Push to Azure Repos.
3. Update build pipelines.
4. Decommission TFVC after a quiet period.

### Service hooks and webhooks

- **Service hooks** — built-in: post to Teams, Slack, Trello, etc. on events.
- **Webhooks** — generic HTTP callbacks for anything else.

### Secrets and credentials in code

Never commit:
- API keys
- Connection strings
- Private certs
- `.env` files

Use **Azure Key Vault** + variable groups (Module 18). For pre-commit scanning, install **GitHub Advanced Security for Azure DevOps** or run `gitleaks` / `truffleHog` locally.

### Analogy

- **Azure Repos** = your company's private GitHub: the same git protocol, with stronger integration to Boards and Pipelines.
- **CODEOWNERS** = auto-assigned subject-matter expert as a reviewer when a PR touches their files.
- **LFS** = a separate warehouse for big crates that don't fit in the regular file cabinet.

## Lab — Polish a real repo with policies, hooks, and templates

**Goal:** turn the bookstore repo into a "production-ready" repo.

1. **PR template** — create `.azuredevops/pull_request_template.md` in the default branch:
   ```markdown
   ## Summary
   <!-- What does this PR do, in 1-2 lines? -->

   ## Why
   <!-- The user/business problem -->

   ## Test plan
   - [ ] Manual smoke test
   - [ ] Unit tests added/updated
   - [ ] Lint passes

   ## Linked work items
   AB#
   ```
2. **README badges** — at the top of `README.md`:
   ```markdown
   ![Build](https://dev.azure.com/<org>/bookstore/_apis/build/status/<pipeline>?branchName=main)
   ```
3. **Branch policies** — verify Module 5 policies still active.
4. **Auto-reviewers** by path:
   - Project Settings → Repositories → Policies → Automatically include reviewers.
   - Add: `/infra/*` → `Platform Team` group.
5. **Service hook** to Microsoft Teams:
   - Project Settings → Service hooks → New → Microsoft Teams → Pull request created.
6. **Disable forks** if your org policy requires it (Repositories → Settings).
7. **Enable secret scanning** if you have GHAS for Azure DevOps:
   - Repos → Settings → Advanced Security → Enable.
   - Push a fake AWS key — expect a blocked push.
8. Commit a small change. Watch:
   - PR template appears.
   - Auto-reviewer triggers.
   - Teams notification fires.

## Trainer notes

- Show **Code search** across the org (powerful when the org has many repos).
- Discussion: "When migrate from TFVC?" — Now, if you're still on it; tooling is mature and the future is Git.
- Common exam trap: `_apis/git/repositories/...` URL structure for cross-project linking.

## Next

➡ [Module 7 — Build Tools: Maven, npm, NuGet](07-build-tools-maven-npm-nuget.md)
⬅ [Module 5 — Branching Strategies](05-branching-strategies.md)
