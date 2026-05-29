# Module 16 — Azure Artifacts

> **AZ-400 domain:** Define and implement a continuous delivery and release management strategy.

## Why this matters

Internal packages need a private home. Azure Artifacts is Microsoft's universal package repo, and the exam asks about feeds, upstream sources, and retention.

## Theory

### What Azure Artifacts is

A private package registry inside Azure DevOps. Supports:

- **NuGet** (.NET)
- **npm** (JavaScript)
- **Maven** (Java)
- **Python (PyPI)**
- **Universal Packages** (anything, ad-hoc)

### Feeds

A **feed** is one registry. You can have many per project:

- Org-level feeds (visible to all projects) or project-level.
- Public or private.
- Per-feed permissions: Reader, Collaborator, Contributor, Owner.

### Upstream sources

A feed can have **upstreams** to public registries (npmjs.com, nuget.org, Maven Central, PyPI):

```
Your build  →  feed `bookstore`  →  upstream: npmjs.com
                                  ↓
                            caches downloaded packages
```

Benefits:
- Builds get **one config** (your feed), not multiple registry URLs.
- Public packages are **cached** — survives upstream outage and accidental deletion (left-pad).
- You can **scan** what's coming in.
- You can **promote** vetted versions to a clean "approved" feed.

### Versioning

Feeds support:
- **Standard semver** (1.2.3).
- **Pre-release tags** (1.2.3-beta.1).
- **Auto-generated** via pipeline ($(Build.BuildId) + $(Build.SourceBranchName)).

### Retention policies

| Setting | Purpose |
|---|---|
| Maximum days to keep recently downloaded versions | Don't delete things people are still pulling |
| Maximum number of versions per package | Cap explosion |
| Permanently delete packages older than N days | Disk hygiene |

Promoted views (`@Release`) bypass retention — useful for keeping prod versions forever.

### Views

A **view** is a filtered slice of the feed: `@Local`, `@Prerelease`, `@Release`. You publish to a view to "promote" a version.

```
feed: bookstore
  versions: 1.0.0, 1.0.1, 1.1.0-beta.1, 1.1.0, 1.2.0
  views:
    @Local        all
    @Prerelease   1.1.0-beta.1
    @Release      1.0.0, 1.0.1, 1.1.0, 1.2.0
```

Consumers can scope to `@Release` so they never accidentally pull a pre-release.

### Publishing from a pipeline

NuGet:

```yaml
- task: DotNetCoreCLI@2
  inputs:
    command: pack
    packagesToPack: '**/*.csproj'
- task: NuGetCommand@2
  inputs:
    command: push
    publishVstsFeed: 'bookstore'   # or feedPublish
```

npm:

```yaml
- task: npmAuthenticate@0
  inputs:
    workingFile: '.npmrc'

- script: npm publish
  displayName: 'Publish to feed'
```

`.npmrc` (committed) tells npm where the feed lives:

```
registry=https://pkgs.dev.azure.com/<org>/<project>/_packaging/bookstore/npm/registry/
always-auth=true
```

### Consuming from a pipeline

The `npmAuthenticate` task injects credentials at job time. For NuGet, use `NuGetAuthenticate@1`.

### Universal Packages

For arbitrary files (not NuGet/npm/Maven/Python):

```bash
az artifacts universal publish \
  --organization https://dev.azure.com/<org> \
  --project bookstore --scope project \
  --feed bookstore-univ --name release-bundle --version 1.0.0 \
  --description "Bookstore deploy bundle" --path ./dist

az artifacts universal download \
  --organization https://dev.azure.com/<org> \
  --project bookstore --scope project \
  --feed bookstore-univ --name release-bundle --version 1.0.0 \
  --path ./downloaded
```

Versioning is enforced; you can't overwrite.

### Permissions

| Role | Can |
|---|---|
| Reader | Pull |
| Collaborator | Pull + push pre-release versions through upstream |
| Contributor | Pull + push |
| Owner | Manage feed |

Lock down `Owner` to a small group; give CI service principals `Contributor`.

### Analogy

- Feed = a private library where your internal books live.
- Upstream = a bookstore the library borrows from when a patron asks for a public book.
- View (`@Release`) = the "approved for adults" section.
- Universal Packages = miscellaneous archives the library stores alongside books.

## Lab — Publish and consume an npm package

**Goal:** publish a tiny private package to Azure Artifacts and use it from another project.

1. **Create a feed** in your project: **Artifacts → + Create Feed → name `bookstore`**, scope: Project.
2. **Author a tiny package**:
   ```bash
   mkdir lib-bookstore-utils && cd lib-bookstore-utils
   npm init -y
   cat > index.js <<'EOF'
   module.exports.greet = name => `Hello, ${name}!`;
   EOF
   ```
3. Add `.npmrc`:
   ```
   registry=https://pkgs.dev.azure.com/<org>/<project>/_packaging/bookstore/npm/registry/
   always-auth=true
   ```
4. Get auth (interactive):
   ```bash
   npx vsts-npm-auth -config .npmrc
   ```
5. Publish:
   ```bash
   npm version 0.1.0
   npm publish
   ```
6. **Consume from a different project**:
   ```bash
   cd ../some-other-app
   npm install @scope/lib-bookstore-utils@0.1.0   # adjust name as appropriate
   ```
7. **Promote to `@Release` view**: Artifacts UI → click the version → Promote → Release.
8. Set a **retention policy**: feed settings → keep 30 days for `@Local`, forever for `@Release`.
9. Add an **upstream source** to `npmjs.com`. Try installing `lodash` — it now flows through your feed and is cached.

## Trainer notes

- Discussion: "Why route through Azure Artifacts for public packages?" — supply chain protection (`event-stream` history); audit; offline resilience.
- Common exam trap: feed scope (Org vs Project) matters — Project-scoped feeds aren't visible from other projects without explicit sharing.

## Next

➡ [Module 17 — Security and Compliance](17-security-compliance.md)
⬅ [Module 15 — IaC with Pipelines](15-iac-with-pipelines.md)
