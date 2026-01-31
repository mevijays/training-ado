# Azure DevOps Pipeline Conditions

## Overview

Pipeline conditions in Azure DevOps allow you to control when jobs, stages, or steps should run based on specific criteria. Conditions provide the logic that determines execution flow, enabling dynamic pipeline behavior based on variables, previous step results, branch names, or custom expressions.

## Understanding Conditions

Conditions are expressions that evaluate to `true` or `false`. When a condition evaluates to `true`, the associated job, stage, or step executes. When it evaluates to `false`, the item is skipped.

### Analogy: Traffic Light System

Think of pipeline conditions like a sophisticated traffic light system at a busy intersection:

- **Green Light (condition: true)**: Traffic flows through - your job/step executes
- **Red Light (condition: false)**: Traffic stops - your job/step is skipped
- **Smart Sensors**: Like conditions that check variables, previous results, or environment states
- **Traffic Controller**: The Azure DevOps engine that evaluates conditions and controls flow
- **Multiple Lanes**: Different jobs/stages that can have different conditions simultaneously

Just as traffic lights prevent accidents and optimize flow, conditions prevent unnecessary work and optimize your pipeline execution.

## Types of Conditions

### 1. Built-in Conditions

```yaml
# Always run (default)
condition: always()

# Only run if all previous steps succeeded
condition: succeeded()

# Only run if previous step failed
condition: failed()

# Run regardless of previous step status
condition: succeededOrFailed()

# Only run if previous step was canceled
condition: canceled()
```

### 2. Variable-based Conditions

```yaml
# Check variable value
condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

# Check multiple variables
condition: and(eq(variables['Build.SourceBranch'], 'refs/heads/main'), eq(variables['System.PullRequest.IsFork'], 'False'))

# Check if variable exists
condition: ne(variables['CustomVariable'], '')
```

### 3. Expression-based Conditions

```yaml
# Complex logical expressions
condition: or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/'))

# Nested conditions
condition: and(succeeded(), or(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['Build.Reason'], 'Manual')))
```

## Comprehensive Example: Multi-Environment Deployment Pipeline

```yaml
trigger:
  branches:
    include:
    - main
    - develop
    - release/*

variables:
  isDevelopBranch: $[eq(variables['Build.SourceBranch'], 'refs/heads/develop')]
  isMainBranch: $[eq(variables['Build.SourceBranch'], 'refs/heads/main')]
  isReleaseBranch: $[startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')]
  deploymentEnvironment: $[if(eq(variables['Build.SourceBranch'], 'refs/heads/main'), 'production', if(eq(variables['Build.SourceBranch'], 'refs/heads/develop'), 'staging', 'testing'))]

stages:
- stage: Build
  displayName: 'Build Application'
  jobs:
  - job: BuildJob
    displayName: 'Build and Test'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: UseDotNet@2
      displayName: 'Setup .NET'
      inputs:
        version: '6.0.x'

    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build application'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration Release --no-restore'

    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration Release --no-build --collect:"XPlat Code Coverage"'

    # Only run code analysis on main and release branches
    - task: SonarCloudPrepare@1
      displayName: 'Prepare SonarCloud analysis'
      condition: or(variables.isMainBranch, variables.isReleaseBranch)
      inputs:
        SonarCloud: 'SonarCloud-Connection'
        organization: 'my-org'
        scannerMode: 'MSBuild'
        projectKey: 'my-project-key'

    - task: SonarCloudAnalyze@1
      displayName: 'Run SonarCloud analysis'
      condition: or(variables.isMainBranch, variables.isReleaseBranch)

    - task: SonarCloudPublish@1
      displayName: 'Publish SonarCloud results'
      condition: or(variables.isMainBranch, variables.isReleaseBranch)

    # Only create artifacts for deployable branches
    - task: DotNetCoreCLI@2
      displayName: 'Publish application'
      condition: or(variables.isMainBranch, variables.isDevelopBranch, variables.isReleaseBranch)
      inputs:
        command: 'publish'
        publishWebProjects: true
        arguments: '--configuration Release --output $(Build.ArtifactStagingDirectory)'

    - task: PublishBuildArtifacts@1
      displayName: 'Publish build artifacts'
      condition: and(succeeded(), or(variables.isMainBranch, variables.isDevelopBranch, variables.isReleaseBranch))
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop'

- stage: DeployDevelopment
  displayName: 'Deploy to Development'
  dependsOn: Build
  condition: and(succeeded(), eq(variables.isDevelopBranch, true))
  jobs:
  - deployment: DeployToDev
    displayName: 'Deploy to Development Environment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: drop

          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Azure-Dev-Connection'
              appType: 'webApp'
              appName: 'myapp-dev'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'

          - task: PowerShell@2
            displayName: 'Run smoke tests'
            inputs:
              targetType: 'inline'
              script: |
                $response = Invoke-WebRequest -Uri "https://myapp-dev.azurewebsites.net/health" -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                  Write-Host "Health check passed"
                } else {
                  Write-Error "Health check failed"
                  exit 1
                }

- stage: DeployStaging
  displayName: 'Deploy to Staging'
  dependsOn: Build
  condition: and(succeeded(), or(variables.isMainBranch, variables.isReleaseBranch))
  jobs:
  - deployment: DeployToStaging
    displayName: 'Deploy to Staging Environment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'staging'
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: drop

          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Azure-Staging-Connection'
              appType: 'webApp'
              appName: 'myapp-staging'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'

          - task: PowerShell@2
            displayName: 'Run integration tests'
            inputs:
              targetType: 'inline'
              script: |
                # Run comprehensive integration tests
                Write-Host "Running integration tests..."
                # Simulate test execution
                Start-Sleep -Seconds 30
                Write-Host "Integration tests completed successfully"

- stage: DeployProduction
  displayName: 'Deploy to Production'
  dependsOn: 
  - Build
  - DeployStaging
  condition: and(succeeded(), eq(variables.isMainBranch, true))
  jobs:
  - deployment: DeployToProd
    displayName: 'Deploy to Production Environment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: drop

          # Pre-deployment validation
          - task: PowerShell@2
            displayName: 'Pre-deployment validation'
            inputs:
              targetType: 'inline'
              script: |
                Write-Host "Validating staging environment before production deployment..."
                $response = Invoke-WebRequest -Uri "https://myapp-staging.azurewebsites.net/health" -UseBasicParsing
                if ($response.StatusCode -ne 200) {
                  Write-Error "Staging environment validation failed"
                  exit 1
                }
                Write-Host "Staging validation passed"

          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Azure-Prod-Connection'
              appType: 'webApp'
              appName: 'myapp-prod'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'
              deploymentMethod: 'zipDeploy'
              takeAppOfflineFlag: true

          # Post-deployment validation
          - task: PowerShell@2
            displayName: 'Post-deployment validation'
            inputs:
              targetType: 'inline'
              script: |
                Write-Host "Validating production deployment..."
                Start-Sleep -Seconds 60  # Wait for app to start
                
                $maxAttempts = 5
                $attempt = 1
                
                do {
                  try {
                    $response = Invoke-WebRequest -Uri "https://myapp-prod.azurewebsites.net/health" -UseBasicParsing
                    if ($response.StatusCode -eq 200) {
                      Write-Host "Production health check passed"
                      break
                    }
                  } catch {
                    Write-Warning "Attempt $attempt failed: $($_.Exception.Message)"
                  }
                  
                  if ($attempt -eq $maxAttempts) {
                    Write-Error "Production validation failed after $maxAttempts attempts"
                    exit 1
                  }
                  
                  $attempt++
                  Start-Sleep -Seconds 30
                } while ($attempt -le $maxAttempts)

- stage: NotifyTeam
  displayName: 'Notify Team'
  dependsOn: 
  - DeployDevelopment
  - DeployStaging
  - DeployProduction
  condition: always()  # Always run regardless of previous stage results
  jobs:
  - job: SendNotification
    displayName: 'Send Deployment Notification'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Send success notification if all previous stages succeeded
    - task: PowerShell@2
      displayName: 'Send success notification'
      condition: and(in(dependencies.DeployDevelopment.result, 'Succeeded', 'Skipped'), in(dependencies.DeployStaging.result, 'Succeeded', 'Skipped'), in(dependencies.DeployProduction.result, 'Succeeded', 'Skipped'))
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Sending success notification to team..."
          # Integration with Teams, Slack, or email service
          $message = "✅ Deployment completed successfully for branch $(Build.SourceBranch) to $(deploymentEnvironment) environment"
          Write-Host $message

    # Send failure notification if any stage failed
    - task: PowerShell@2
      displayName: 'Send failure notification'
      condition: or(eq(dependencies.DeployDevelopment.result, 'Failed'), eq(dependencies.DeployStaging.result, 'Failed'), eq(dependencies.DeployProduction.result, 'Failed'))
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Sending failure notification to team..."
          $message = "❌ Deployment failed for branch $(Build.SourceBranch). Please check the pipeline logs."
          Write-Host $message
          # Add actual notification logic here
```

## Advanced Condition Patterns

### 1. Time-based Conditions

```yaml
# Only run during business hours (UTC)
- task: PowerShell@2
  condition: and(succeeded(), ge(format('{0:HH}', pipeline.startTime), 9), le(format('{0:HH}', pipeline.startTime), 17))
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Running during business hours"'

# Only run on weekdays
- task: PowerShell@2
  condition: and(succeeded(), ne(format('{0:dddd}', pipeline.startTime), 'Saturday'), ne(format('{0:dddd}', pipeline.startTime), 'Sunday'))
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Running on weekday"'
```

### 2. File Change Conditions

```yaml
# Only run if specific files changed
- task: PowerShell@2
  condition: and(succeeded(), contains(variables['Build.SourceVersionMessage'], 'database'))
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Database migration detected"'

# Custom condition based on changed files
- bash: |
    if git diff --name-only HEAD^ HEAD | grep -q "src/"; then
      echo "##vso[task.setvariable variable=sourceChanged]true"
    else
      echo "##vso[task.setvariable variable=sourceChanged]false"
    fi
  displayName: 'Check for source changes'

- task: DotNetCoreCLI@2
  condition: and(succeeded(), eq(variables.sourceChanged, 'true'))
  inputs:
    command: 'build'
```

### 3. Environment-specific Conditions

```yaml
variables:
  isProduction: $[eq(variables['System.StageName'], 'Production')]
  isDevelopment: $[eq(variables['System.StageName'], 'Development')]

steps:
# Enable detailed logging only in development
- task: PowerShell@2
  condition: variables.isDevelopment
  inputs:
    targetType: 'inline'
    script: |
      Write-Host "##vso[task.setvariable variable=system.debug]true"
      Write-Host "Debug logging enabled for development"

# Skip time-consuming tasks in development
- task: PowerShell@2
  displayName: 'Performance tests'
  condition: variables.isProduction
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Running performance tests for production"'
```

## Best Practices

### 1. Keep Conditions Simple and Readable

```yaml
# Good: Clear and understandable
condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))

# Avoid: Overly complex nested conditions
condition: and(or(and(succeeded(), eq(variables['var1'], 'value1')), and(failed(), eq(variables['var2'], 'value2'))), not(eq(variables['var3'], 'value3')))
```

### 2. Use Variables for Complex Logic

```yaml
variables:
  shouldDeploy: $[and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')))]

steps:
- task: AzureWebApp@1
  condition: variables.shouldDeploy
```

### 3. Document Complex Conditions

```yaml
# Deploy only if:
# 1. Previous steps succeeded
# 2. Branch is main or release branch
# 3. Not a pull request build
- task: AzureWebApp@1
  condition: and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')), ne(variables['Build.Reason'], 'PullRequest'))
```

### 4. Handle Failed Dependencies Gracefully

```yaml
- stage: Cleanup
  dependsOn: 
  - Deploy
  condition: always()  # Run cleanup regardless of deployment result
  jobs:
  - job: CleanupResources
    steps:
    - task: PowerShell@2
      condition: eq(dependencies.Deploy.result, 'Failed')
      inputs:
        targetType: 'inline'
        script: 'Write-Host "Cleaning up after failed deployment"'
```

## Common Condition Functions

| Function | Description | Example |
|----------|-------------|---------|
| `always()` | Always run | `condition: always()` |
| `succeeded()` | Run if previous succeeded | `condition: succeeded()` |
| `failed()` | Run if previous failed | `condition: failed()` |
| `canceled()` | Run if previous canceled | `condition: canceled()` |
| `succeededOrFailed()` | Run if not canceled | `condition: succeededOrFailed()` |
| `eq(a, b)` | Equality comparison | `condition: eq(variables.branch, 'main')` |
| `ne(a, b)` | Not equal comparison | `condition: ne(variables.env, '')` |
| `and(a, b)` | Logical AND | `condition: and(succeeded(), eq(variables.deploy, 'true'))` |
| `or(a, b)` | Logical OR | `condition: or(eq(variables.env, 'dev'), eq(variables.env, 'test'))` |
| `not(a)` | Logical NOT | `condition: not(eq(variables.skip, 'true'))` |
| `contains(a, b)` | String contains | `condition: contains(variables.message, 'deploy')` |
| `startsWith(a, b)` | String starts with | `condition: startsWith(variables.branch, 'feature/')` |
| `endsWith(a, b)` | String ends with | `condition: endsWith(variables.file, '.json')` |

## Troubleshooting Conditions

### 1. Debug Condition Evaluation

```yaml
- task: PowerShell@2
  displayName: 'Debug variables'
  inputs:
    targetType: 'inline'
    script: |
      Write-Host "Build.SourceBranch: $(Build.SourceBranch)"
      Write-Host "Build.Reason: $(Build.Reason)"
      Write-Host "Custom variable: $(myVariable)"
```

### 2. Test Conditions in Different Scenarios

```yaml
- task: PowerShell@2
  displayName: 'Test condition'
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  inputs:
    targetType: 'inline'
    script: 'Write-Host "This runs only on main branch"'
```

### 3. Use Runtime Variables for Dynamic Conditions

```yaml
- bash: |
    if [ "$(date +%u)" -gt 5 ]; then
      echo "##vso[task.setvariable variable=isWeekend]true"
    else
      echo "##vso[task.setvariable variable=isWeekend]false"
    fi
  displayName: 'Check if weekend'

- task: PowerShell@2
  condition: eq(variables.isWeekend, 'false')
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Running weekday task"'
```

Conditions are powerful tools for creating intelligent, responsive pipelines that adapt to different scenarios and requirements. Master them to build sophisticated CI/CD workflows that optimize resource usage and ensure appropriate deployments.
