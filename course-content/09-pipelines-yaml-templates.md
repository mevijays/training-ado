# Module 9 — YAML Pipelines and Templates

> **AZ-400 domain:** Define and implement continuous integration.

## Why this matters

Once you have one pipeline, you'll want a second, third, twentieth. **Templates** keep them DRY. The exam asks templated-pipeline scenarios.

## Theory

### Template types

| Template type | Purpose |
|---|---|
| **Step template** | Reusable list of steps |
| **Job template** | Reusable job |
| **Stage template** | Reusable stage |
| **Variable template** | Reusable variable blocks |

### Step template example

`templates/steps-build-node.yml`:

```yaml
parameters:
  - name: nodeVersion
    type: string
    default: '20.x'
  - name: workingDirectory
    type: string
    default: '$(Build.SourcesDirectory)'

steps:
  - task: NodeTool@0
    inputs: { versionSpec: ${{ parameters.nodeVersion }} }
  - script: npm ci
    workingDirectory: ${{ parameters.workingDirectory }}
  - script: npm run build
    workingDirectory: ${{ parameters.workingDirectory }}
  - script: npm test
    workingDirectory: ${{ parameters.workingDirectory }}
```

Caller:

```yaml
steps:
  - template: templates/steps-build-node.yml
    parameters:
      nodeVersion: '22.x'
      workingDirectory: 'apps/api'
```

### Job template

`templates/jobs-build.yml`:

```yaml
parameters:
  - name: name
    type: string
  - name: pool
    type: object
    default: { vmImage: ubuntu-latest }

jobs:
  - job: ${{ parameters.name }}
    pool: ${{ parameters.pool }}
    steps:
      - template: steps-build-node.yml
```

### Stage template

```yaml
parameters:
  - name: env
    type: string
  - name: dependsOn
    type: string
    default: ''

stages:
  - stage: Deploy_${{ parameters.env }}
    dependsOn: ${{ parameters.dependsOn }}
    jobs:
      - deployment: deploy
        environment: ${{ parameters.env }}
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploying to ${{ parameters.env }}"
```

### Expressions: `${{ }}` vs `$()`

Three syntaxes:

| Syntax | When evaluated | Use |
|---|---|---|
| `${{ ... }}` | Compile-time (when YAML is parsed) | Parameters, conditionals on structure |
| `$(name)` | Runtime (when agent runs the step) | Variables in commands and inputs |
| `$[ ... ]` | Runtime expression | Computed runtime values |

Examples:

```yaml
${{ if eq(parameters.env, 'prod') }}:
  pool:
    vmImage: ubuntu-latest

steps:
  - script: echo $(Build.BuildId)
  - script: echo $[ counter('release', 1) ]
```

### `extends` template

A full pipeline can `extends` from a template — useful for org-wide standards:

```yaml
# azure-pipelines.yml in a consumer repo
extends:
  template: pipeline-template.yml@templates
  parameters:
    appName: bookstore

resources:
  repositories:
    - repository: templates
      type: git
      name: my-project/templates
      ref: refs/heads/main
```

This is how a platform team enforces "every pipeline has SAST, every prod deploy has approval."

### Required and approved templates

You can require pipelines to extend a specific template via **Pipeline policies** in project settings. The exam mentions this for governance scenarios.

### Multi-stage pipelines

```yaml
stages:
  - stage: Build
    jobs:
      - job: build
        steps: [...]

  - stage: Deploy_Dev
    dependsOn: Build
    jobs:
      - deployment: deploy
        environment: dev
        strategy:
          runOnce: { deploy: { steps: [...] } }

  - stage: Deploy_Prod
    dependsOn: Deploy_Dev
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: deploy
        environment: prod
```

### Deployment jobs

`deployment` is a special job type with:
- `environment` reference (with approvals/checks).
- Strategies: `runOnce`, `rolling`, `canary`.

### Parameter types

```yaml
parameters:
  - name: env
    type: string
    values: [dev, stage, prod]
  - name: regions
    type: object
    default: [eastus, westeurope]
  - name: enableTests
    type: boolean
    default: true
```

### Analogy

- A template is a **function**.
- Parameters are its arguments.
- Calling the template = invoking the function.
- `extends` = an abstract class your concrete pipeline implements.

## Lab — Templated multi-stage pipeline

**Goal:** refactor the Module 8 pipeline using templates and add a deploy stage.

1. Create `templates/steps-build-node.yml` and `templates/stages-deploy.yml` as shown above.
2. Refactor your `azure-pipelines.yml`:
   ```yaml
   trigger: [main]

   stages:
     - stage: Build
       jobs:
         - job: build
           pool: { vmImage: ubuntu-latest }
           steps:
             - template: templates/steps-build-node.yml
               parameters:
                 nodeVersion: '20.x'
             - task: PublishPipelineArtifact@1
               inputs:
                 targetPath: 'dist'
                 artifactName: 'app'

     - template: templates/stages-deploy.yml
       parameters:
         env: dev
         dependsOn: Build

     - template: templates/stages-deploy.yml
       parameters:
         env: prod
         dependsOn: Deploy_dev
   ```
3. Create environments `dev` and `prod` in Pipelines → Environments. Add an **approval** check on `prod`.
4. Run the pipeline. Watch it stop at prod for approval; approve.
5. Try changing a parameter (e.g., bump `nodeVersion` to `22.x`) — confirm it propagates through all calls.

## Trainer notes

- Spend time on `${{ }}` vs `$()` — single biggest source of confusion.
- Discussion: "Where do shared templates live?" — usually in a separate `templates` repo, referenced via `resources.repositories`.
- Common exam trap: deployment jobs require an `environment`, which auto-creates on first use but gets approvals only when configured.

## Next

➡ [Module 10 — Self-hosted Agents](10-self-hosted-agents.md)
⬅ [Module 8 — Azure Pipelines CI Basics](08-azure-pipelines-ci.md)
