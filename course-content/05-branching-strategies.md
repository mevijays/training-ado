# Module 5 — Branching Strategies

> **AZ-400 domain:** Design and implement a source control strategy.

## Why this matters

The strategy you pick shapes how fast you can ship, how stable `main` is, and how painful merges become. The exam asks scenario questions about which strategy fits which team.

## Theory

### Trunk-Based Development (TBD)

- One long-lived branch: `main` (or `trunk`).
- Short-lived feature branches (≤ 1-2 days).
- Frequent integration to `main` behind feature flags.
- Releases tagged from `main`.

```
main:  A---B---C---D---E---F---G
              \-/   \-/
              short feature branches
```

**Best for:** teams with strong CI, feature flags, and continuous deployment.

### GitHub Flow

A flavor of TBD popularized by GitHub:

1. Branch off `main`.
2. Add commits.
3. Open PR; CI runs.
4. Discuss + review.
5. Deploy from the branch to test (some teams).
6. Merge to `main`.
7. Deploy `main` to prod.

**Best for:** SaaS apps with continuous deployment.

### GitFlow

A more elaborate model from 2010:

```
main:    A----------M1-----------M2     (releases)
                   /            /
release:  ─────RC1            RC2
develop:  D1-D2-D3-D4-D5-D6-D7
              \  /  \  /
            feature branches
            
hotfix:                     H1 -> patches main + develop
```

Branches: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`.

**Best for:** packaged software with versioned releases (think: shipped CDs).

**Not great for:** modern SaaS — too many branches, slow integration.

### Release Flow (used by Microsoft internally)

A trunk-based variant with **release branches** for cherry-picking hotfixes:

- All work merges to `main`.
- For each release, branch `release/2026-03` off `main`.
- Hotfixes go to `main` first, then are cherry-picked to active release branches.

**Best for:** teams with long-tail customers running multiple versions.

### Comparison

| Strategy | Branches | Best for |
|---|---|---|
| Trunk-based | 1 + tiny feature | High-velocity SaaS |
| GitHub Flow | 1 + feature | Web apps with CD |
| GitFlow | 5 categories | Packaged versioned software |
| Release Flow | 1 + release | Microsoft-scale multi-version |

### Branch protection / branch policies

These enforce process at the repo level:

- Require N reviewers on PRs.
- Require build to pass.
- Require linked work items.
- Require comment resolution.
- Restrict who can push directly.
- Auto-include reviewers (CODEOWNERS).
- Path-based reviewer assignment.

In Azure Repos: **Project Settings → Repos → Policies**. In GitHub: **Settings → Branches → Branch protection rules**.

### Commit message conventions

[Conventional Commits](https://www.conventionalcommits.org/):

```
feat(search): add author filter
fix(auth): handle expired tokens
docs: update README
chore: bump dependencies
```

Enables auto-generated changelogs (`semantic-release`).

### Squash vs merge commit vs rebase merge

| Strategy | Result on main | Use |
|---|---|---|
| **Squash** | One commit per PR | Most teams. Clean main. |
| **Merge commit** | Preserves feature history + merge commit | When the branch history matters |
| **Rebase merge** | Linear, no merge commit | OCD-clean histories |

### Analogy

- **Trunk-based** = a busy kitchen — everyone working on the same counter, finishing dishes constantly.
- **GitFlow** = a banquet hall with separate prep rooms, plating room, finishing kitchen — slow but organized.
- **Release Flow** = a publishing house — drafts go to `main`, the editor branches a release per book version.

## Lab — Apply branch policies in Azure Repos

**Goal:** enforce real protection on `main`.

1. In the `bookstore` Azure Repos, go to **Project Settings → Repositories → (your repo) → Policies → Branch policies → main**.
2. Configure:
   - **Require a minimum number of reviewers**: 1.
   - **Check for linked work items**: required (you'll need `AB#123` in PR titles).
   - **Check for comment resolution**: required.
   - **Limit merge types**: only squash + rebase.
   - **Build validation**: skip for now; we'll add in Module 8.
3. Try to push directly to `main`:
   ```bash
   git switch main
   echo "direct push" >> README.md
   git commit -am "direct push attempt"
   git push
   ```
   Should fail.
4. Use the proper flow:
   ```bash
   git switch -c feat/test-policy
   echo "via PR" >> README.md
   git commit -am "Update via PR AB#1"
   git push -u origin feat/test-policy
   ```
5. Open a PR in the Azure Repos UI. Try to complete with no reviewer — fails. Add yourself, approve, complete.
6. Use **squash** as the merge method.
7. Verify `main` history is linear.

## Trainer notes

- Discussion: "When is GitFlow still right?" — packaged or embedded software where customers don't auto-upgrade.
- Common exam trap: branch policies live on the destination branch, not the source.
- Show CODEOWNERS file in action — auto-assigns reviewers by path.

## Next

➡ [Module 6 — Azure Repos](06-azure-repos.md)
⬅ [Module 4 — Git Version Control](04-git-version-control.md)
