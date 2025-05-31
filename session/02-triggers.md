# Azure DevOps Pipeline Triggers

## Overview
Triggers in Azure DevOps Pipelines define the events that automatically start a pipeline execution. They are the gatekeepers that determine when your CI/CD process should run, ensuring your code is built, tested, and deployed at the right moments.

## Explanation
Triggers are event-driven mechanisms that monitor for specific conditions and automatically initiate pipeline runs when those conditions are met. Azure DevOps supports several types of triggers:

1. **CI Triggers (Push Triggers)**: Run when code is pushed to specified branches
2. **PR Triggers (Pull Request Triggers)**: Run when pull requests are created or updated
3. **Scheduled Triggers**: Run at specific times or intervals
4. **Pipeline Triggers**: Run when other pipelines complete
5. **Manual Triggers**: Require manual initiation

## What Are Triggers?

Triggers are essentially "watchers" that continuously monitor your repository and other resources for changes. When a trigger condition is satisfied, it signals the Azure DevOps service to queue and execute your pipeline.

### Key Concepts:
- **Event-driven automation**: No manual intervention required
- **Branch-specific**: Can target specific branches or branch patterns
- **Path-based filtering**: Can trigger based on file path changes
- **Conditional logic**: Support complex conditions for when to trigger

## Analogy
Think of triggers like a security system in your home:

- **Motion sensors** (CI triggers) - detect when someone enters (code is pushed)
- **Door sensors** (PR triggers) - detect when someone tries to enter (pull request created)
- **Timer-based alarms** (scheduled triggers) - activate at specific times (daily backup)
- **Connected alarms** (pipeline triggers) - one alarm triggers another (security system activates lights)
- **Manual switches** (manual triggers) - you control when to activate (testing mode)

Just like you configure your security system to respond to different events, you configure pipeline triggers to respond to different development events.

## Types of Triggers in Detail

### 1. CI Triggers (Continuous Integration)
Automatically run when code is pushed to specified branches.

### 2. PR Triggers (Pull Request)
Run when pull requests are created, updated, or merged.

### 3. Scheduled Triggers
Execute pipelines at predetermined times using cron expressions.

### 4. Pipeline Resource Triggers
Trigger when dependent pipelines complete successfully.

### 5. Manual Triggers
Require human intervention to start the pipeline.

## Example Workflow YAML

```yaml
# Pipeline with comprehensive trigger configuration
name: 'Advanced Trigger Configuration'

# CI Trigger Configuration
trigger:
  branches:
    include:
      - main
      - develop
      - 'release/*'
      - 'hotfix/*'
    exclude:
      - 'feature/experimental'
  paths:
    include:
      - 'src/*'
      - 'tests/*'
      - 'docs/*'
    exclude:
      - 'README.md'
      - '*.txt'
  tags:
    include:
      - 'v*'
      - 'release-*'

# Pull Request Trigger Configuration
pr:
  branches:
    include:
      - main
      - develop
    exclude:
      - 'feature/temp-*'
  paths:
    include:
      - 'src/*'
      - 'tests/*'
    exclude:
      - 'docs/*'
      - '*.md'
  drafts: false  # Don't trigger on draft PRs

# Scheduled Trigger Configuration
schedules:
  - cron: '0 2 * * *'  # Daily at 2 AM
    displayName: 'Nightly Build'
    branches:
      include:
        - main
    always: true  # Run even if no changes

  - cron: '0 6 * * 1'  # Weekly on Monday at 6 AM
    displayName: 'Weekly Integration Test'
    branches:
      include:
        - develop
    always: false  # Only run if there are changes

# Pipeline Resource Triggers
resources:
  pipelines:
    - pipeline: 'upstream-build'
      source: 'MyProject-Build'
      project: 'MyProject'
      trigger:
        branches:
          include:
            - main
            - develop

# Variables
variables:
  - name: 'triggerReason'
    value: $(Build.Reason)
  - name: 'sourceBranch'
    value: $(Build.SourceBranch)

# Agent pool
pool:
  vmImage: 'ubuntu-latest'

# Pipeline stages
stages:
  - stage: 'TriggerInfo'
    displayName: 'Display Trigger Information'
    jobs:
      - job: 'ShowTriggerDetails'
        displayName: 'Show Trigger Details'
        steps:
          - script: |
              echo "Pipeline triggered by: $(triggerReason)"
              echo "Source branch: $(sourceBranch)"
              echo "Build ID: $(Build.BuildId)"
              echo "Build number: $(Build.BuildNumber)"
              
              case "$(triggerReason)" in
                "IndividualCI")
                  echo "✅ Triggered by CI (code push)"
                  ;;
                "PullRequest")
                  echo "🔄 Triggered by Pull Request"
                  echo "PR ID: $(System.PullRequest.PullRequestId)"
                  echo "PR Source Branch: $(System.PullRequest.SourceBranch)"
                  echo "PR Target Branch: $(System.PullRequest.TargetBranch)"
                  ;;
                "Schedule")
                  echo "⏰ Triggered by schedule"
                  ;;
                "ResourceTrigger")
                  echo "🔗 Triggered by pipeline resource"
                  ;;
                "Manual")
                  echo "👤 Triggered manually"
                  ;;
                *)
                  echo "❓ Unknown trigger reason"
                  ;;
              esac
            displayName: 'Display trigger information'

  - stage: 'ConditionalStage'
    displayName: 'Conditional Stage Based on Trigger'
    dependsOn: 'TriggerInfo'
    condition: or(eq(variables['Build.Reason'], 'IndividualCI'), eq(variables['Build.Reason'], 'PullRequest'))
    jobs:
      - job: 'ConditionalJob'
        displayName: 'Run Only for CI or PR'
        steps:
          - script: |
              echo "This job only runs for CI or PR triggers"
              echo "Current trigger: $(Build.Reason)"
            displayName: 'Conditional execution'

  - stage: 'ScheduledOnlyStage'
    displayName: 'Scheduled Build Stage'
    dependsOn: 'TriggerInfo'
    condition: eq(variables['Build.Reason'], 'Schedule')
    jobs:
      - job: 'NightlyTasks'
        displayName: 'Nightly Maintenance Tasks'
        steps:
          - script: |
              echo "Running nightly maintenance tasks"
              echo "Performing database cleanup"
              echo "Generating daily reports"
              echo "Running comprehensive tests"
            displayName: 'Execute nightly tasks'

  - stage: 'BranchSpecificStage'
    displayName: 'Branch-Specific Processing'
    dependsOn: 'TriggerInfo'
    condition: |
      or(
        startsWith(variables['Build.SourceBranch'], 'refs/heads/release/'),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
    jobs:
      - job: 'ProductionPrep'
        displayName: 'Production Preparation'
        steps:
          - script: |
              echo "Preparing for production deployment"
              if [[ "$(Build.SourceBranch)" == *"release/"* ]]; then
                echo "Processing release branch: $(Build.SourceBranch)"
                echo "Running release-specific validations"
              elif [[ "$(Build.SourceBranch)" == *"main"* ]]; then
                echo "Processing main branch"
                echo "Running production deployment checks"
              fi
            displayName: 'Branch-specific processing'
```

## Advanced Trigger Patterns

### Path-based Triggers
```yaml
trigger:
  branches:
    include: ['main']
  paths:
    include: ['src/api/*']  # Only trigger for API changes
    exclude: ['docs/*']     # Ignore documentation changes
```

### Tag-based Triggers
```yaml
trigger:
  tags:
    include: ['v*']  # Trigger on version tags like v1.0.0
```

### Disable Triggers
```yaml
trigger: none  # Disable all CI triggers
pr: none       # Disable all PR triggers
```

## Best Practices

1. **Use branch patterns wisely**: Include only necessary branches to avoid unnecessary builds
2. **Implement path filtering**: Exclude non-code files like documentation to save build minutes
3. **Schedule builds appropriately**: Avoid peak hours for scheduled builds
4. **Use draft PR exclusion**: Prevent builds on incomplete work
5. **Monitor trigger patterns**: Review which triggers fire most frequently
6. **Combine conditions**: Use multiple trigger types for comprehensive coverage
7. **Document trigger logic**: Comment complex trigger configurations

## Common Trigger Scenarios

- **Feature Development**: PR triggers for feature branches
- **Release Management**: CI triggers for release branches with tag triggers
- **Hotfix Deployment**: Immediate triggers for hotfix branches
- **Nightly Builds**: Scheduled triggers for comprehensive testing
- **Integration Testing**: Pipeline triggers after successful builds

Understanding and properly configuring triggers is essential for an efficient CI/CD workflow that responds appropriately to development activities.
