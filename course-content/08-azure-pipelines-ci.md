# Module 8 — Azure Pipelines — CI Basics

> **AZ-400 domain:** Define and implement continuous integration. **Largest exam weight (20-25%).**

## Why this matters

Pipelines are the heart of Azure DevOps and AZ-400. You must be able to read, write, and debug them — and explain *why* each piece is there.

## Theory

### Pipeline mental model

```
Pipeline
└── Stage (e.g. "Build", "Deploy-Dev")
    └── Job (e.g. "Build linux", "Build windows")
        └── Step (e.g. "npm install", "npm test")
```

Stages run sequentially by default (with dependsOn customization). Jobs in a stage run in parallel by default. Steps in a job run sequentially.

### Classic vs YAML pipelines

- **Classic** — designed in the UI, stored as XML. Legacy. Don't use for new work.
- **YAML** — defined in code, in the repo. Versioned, reviewable, the future. AZ-400 focuses heavily on YAML.

### Minimal YAML pipeline

```yaml
trigger:
  branches:
    include: [main]

pool:
  vmImage: ubuntu-latest

steps:
  - script: echo "Hello, pipelines"
  - script: |
      echo "Multi-line"
      date
```

Save as `azure-pipelines.yml` in the repo root.

### Triggers

| Trigger | When |
|---|---|
| `trigger:` | CI on push to listed branches/paths |
| `pr:` | PR validation |
| `schedules:` | Cron-style |
| `resources.pipelines:` | When another pipeline completes |
| `resources.repositories:` | When another repo updates |
| Manual / "Run pipeline" | Always |

### Pool: where the job runs

```yaml
pool:
  vmImage: ubuntu-latest           # Microsoft-hosted
  # or
  name: my-self-hosted-pool
  demands: [agent.os -equals Linux]
```

Microsoft-hosted images: `ubuntu-latest`, `windows-latest`, `macos-latest`. Reset each job.

### Variables

```yaml
variables:
  buildConfiguration: Release
  imageTag: $(Build.BuildId)

steps:
  - script: echo $(buildConfiguration) and $(imageTag)
```

Variable sources, in precedence (low → high):
1. Pipeline-level vars
2. Stage-level vars
3. Job-level vars
4. Variable groups (Library)
5. Runtime parameters
6. Predefined variables (`$(Build.BuildId)`, `$(Agent.OS)`, `$(System.AccessToken)`, etc.)

### Secrets in variables

Mark a variable as **secret** in the UI (or use a Key Vault-backed variable group). Secrets are masked in logs and not auto-exposed as env vars — you must map them explicitly:

```yaml
- script: echo $MYTOKEN  # won't work
  env:
    MYTOKEN: $(my-secret-var)
```

### Tasks vs scripts

```yaml
- task: UseNode@1
  inputs:
    version: '20.x'

- script: npm ci && npm test
  displayName: 'Build and test'
```

- **Task** = a pre-built building block (`UseNode`, `Docker`, `AzureCLI`).
- **Script** = inline shell. Use for custom logic; tasks for common needs.

### Build → publish artifact pattern

```yaml
steps:
  - task: NodeTool@0
    inputs: { versionSpec: '20.x' }
  - script: |
      npm ci
      npm run build
      npm test
  - task: PublishPipelineArtifact@1
    inputs:
      targetPath: 'dist/'
      artifactName: 'app'
```

The artifact becomes downloadable by later stages/pipelines.

### Conditions

```yaml
- script: ./deploy.sh
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

Common: `always()`, `succeeded()`, `failed()`, `eq()`, `ne()`, `and()`, `or()`.

### Caching

```yaml
- task: Cache@2
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    path: '~/.npm'
```

Speeds repeated builds dramatically.

### Analogy

- **Pipeline** = an assembly line.
- **Stage** = a station (Build → Test → Package → Deploy).
- **Job** = a worker at one station (e.g., two workers in parallel on different OSes).
- **Step** = one motion the worker performs.
- **Agent** = the worker themselves; pools are the labor union.
- **Artifact** = the output of one station, fed into the next.

## Lab — First CI pipeline

**Goal:** stand up a real CI pipeline that builds and tests a Node app.

1. In your Azure Repos project, add this `azure-pipelines.yml` at the root of a small Node project:
   ```yaml
   trigger:
     branches: { include: [main] }

   pr:
     branches: { include: [main] }

   pool:
     vmImage: ubuntu-latest

   variables:
     nodeVersion: '20.x'

   steps:
     - task: NodeTool@0
       inputs: { versionSpec: $(nodeVersion) }
       displayName: 'Use Node $(nodeVersion)'

     - task: Cache@2
       inputs:
         key: 'npm | "$(Agent.OS)" | package-lock.json'
         path: '~/.npm'
         restoreKeys: |
           npm | "$(Agent.OS)"
       displayName: 'Cache npm'

     - script: npm ci
       displayName: 'npm ci'

     - script: npm run build --if-present
       displayName: 'Build'

     - script: npm test --if-present
       displayName: 'Test'

     - task: PublishPipelineArtifact@1
       inputs:
         targetPath: 'dist'
         artifactName: 'app'
       condition: succeededOrFailed()
       displayName: 'Publish dist/'
   ```
2. Commit, push. Pipeline auto-runs.
3. Inspect the pipeline run UI: stages → jobs → steps → logs.
4. **Add a build validation policy** for `main`: Project Settings → Repos → Policies → main → Build validation → add your pipeline.
5. Open a PR with a failing test → CI fails → PR can't merge.
6. Fix it, push again, merge.

## Trainer notes

- Show **rerun failed jobs** to save minutes when only one job out of many fails.
- Discussion: "Why use `npm ci` not `npm install` in CI?" — strict lockfile usage.
- Common exam trap: PR triggers (`pr:`) require the YAML in the **target** branch. Drives students up the wall.

## Next

➡ [Module 9 — YAML Pipelines and Templates](09-pipelines-yaml-templates.md)
⬅ [Module 7 — Build Tools: Maven, npm, NuGet](07-build-tools-maven-npm-nuget.md)
