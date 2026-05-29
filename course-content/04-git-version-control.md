# Module 4 — Git Version Control

> **AZ-400 domain:** Design and implement a source control strategy.

## Why this matters

Git is the universal source control. The exam expects fluency in the core verbs and the ability to debug conflicts.

## Theory

### Why Git won

Distributed, fast, branches are cheap, the diff/merge engine is excellent, and GitHub/GitLab/Azure Repos all use it.

### The three trees

```
working dir   →   staging   →   commit (HEAD)
   (edits)      (git add)     (git commit)
```

- **Working directory** — the files you edit.
- **Staging / index** — `git add`-ed changes ready for the next commit.
- **HEAD** — last commit on the current branch.
- **Remote** — origin server (Azure Repos, GitHub, GitLab).

### Essential commands

```bash
git init                      # start a repo
git clone <url>               # clone existing
git status                    # what's changed
git add <file>                # stage
git commit -m "msg"           # snapshot
git log --oneline --graph     # history
git diff                      # unstaged changes
git diff --staged             # staged changes
git push                      # send to remote
git pull                      # fetch + merge
git fetch                     # just fetch
git branch                    # list local branches
git branch <name>             # create branch
git checkout <name>           # switch
git switch <name>             # newer alias for checkout
git switch -c <name>          # create+switch
git merge <branch>            # merge into current
git rebase <branch>           # replay current onto branch
git tag v1.0.0                # tag this commit
git stash                     # set aside changes
git revert <hash>             # safe undo (new commit)
git reset --hard <hash>       # destructive undo
```

### Merge vs rebase

Both combine branches. Different histories:

```
merge:  A---B---C---M    M = merge commit
             /
          D---E

rebase: A---B---C---D'---E'   D and E are replayed on top of C
```

- **Merge** preserves history; explicit merge commit shows the branching.
- **Rebase** rewrites history; linear, but you must not rebase shared branches.

Rule of thumb: **rebase your own private branch before opening a PR; merge in shared history**.

### Pull request flow (Azure Repos / GitHub)

1. Create a feature branch: `git switch -c feat/search`.
2. Commit work in small chunks.
3. Push: `git push -u origin feat/search`.
4. Open a PR against `main`.
5. CI runs (build + test).
6. Reviewers comment / approve.
7. Merge (squash, rebase, or merge-commit, depending on team policy).
8. Delete branch.

### Resolving conflicts

When git can't auto-merge:

```bash
git pull   # produces conflicts
# edit files, look for <<<<<<<, =======, >>>>>>> markers
git add <resolved-files>
git commit
```

VS Code, Cursor, and Claude Code all have UIs for picking sides.

### .gitignore

A file at the repo root telling git to ignore patterns:

```
node_modules/
*.log
.env
dist/
.terraform/
*.tfstate
```

### Tags vs branches

- **Branch** = mobile pointer that advances with new commits.
- **Tag** = fixed pointer to one commit (often a release like `v1.2.0`).

### Submodules and subtrees

For including one repo inside another. Use sparingly — most teams find them painful.

### Analogy: a shared Google Doc with time travel

- Each commit = "Save with comment".
- Branch = a copy of the doc you edit privately.
- Merge = paste your edits back into the master copy, resolving any overlap.
- Rebase = "redo my edits on top of the latest master."
- Reset = "time machine, take me back to this save point."

## Lab — Hands-on Git

**Goal:** practice the essential workflow.

1. Make a folder + init:
   ```bash
   mkdir ~/labs/04-git && cd ~/labs/04-git
   git init
   echo "# Lab 4" > README.md
   git add README.md
   git commit -m "Initial commit"
   ```
2. Add a remote (use an empty Azure Repos repo from the `bookstore` project):
   ```bash
   git remote add origin https://dev.azure.com/<org>/bookstore/_git/<repo>
   git push -u origin main
   ```
3. Create a feature branch:
   ```bash
   git switch -c feat/intro
   echo "Hello" > greet.txt
   git add greet.txt
   git commit -m "Add greeting"
   git push -u origin feat/intro
   ```
4. Open a PR in Azure Repos. Note that no policies block it (yet).
5. Cause a conflict:
   ```bash
   git switch main
   echo "Different content" > greet.txt
   git add greet.txt
   git commit -m "Conflicting greeting"
   git push
   git switch feat/intro
   git pull origin main   # produces conflict
   # edit greet.txt, resolve, then:
   git add greet.txt
   git commit
   git push
   ```
6. **Squash merge** the PR in Azure Repos. Confirm `main` history is clean.
7. Tag a release:
   ```bash
   git switch main
   git pull
   git tag v0.1.0
   git push origin v0.1.0
   ```
8. Try a `git revert` of the latest commit (safe undo).

## Trainer notes

- Live-demo a conflict. Students learn by watching the markers appear.
- Discussion: "Squash merge vs merge commit vs rebase merge?" — squash is most common for feature PRs because it keeps `main` history readable.
- Common student mistake: `git pull` on a dirty working dir. Use `git stash` first.

## Next

➡ [Module 5 — Branching Strategies](05-branching-strategies.md)
⬅ [Module 3 — Agile Planning with Azure Boards](03-agile-boards.md)
