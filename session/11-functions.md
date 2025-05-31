# Azure DevOps Pipeline Functions and Expressions

## Overview

Azure DevOps pipelines provide a rich set of built-in functions and expression syntax that enable dynamic behavior, data manipulation, and conditional logic. These functions allow you to create intelligent pipelines that adapt to different scenarios, process data, and make decisions based on runtime conditions.

## Understanding Functions and Expressions

Functions in Azure DevOps are predefined operations that you can use in pipeline expressions to manipulate data, check conditions, and control pipeline behavior. Expressions are evaluated at runtime and can include variables, functions, and operators.

### Analogy: Smart Kitchen Assistant

Think of pipeline functions like a smart kitchen assistant with various tools and abilities:

- **Recipe Calculator (Math Functions)**: Automatically adjusts ingredient quantities, cooking times
- **Ingredient Checker (String Functions)**: Verifies what's available, checks expiration dates
- **Schedule Coordinator (Date/Time Functions)**: Plans cooking times, coordinates multiple dishes
- **Quality Inspector (Condition Functions)**: Checks if each step completed successfully
- **Pantry Manager (Array Functions)**: Organizes ingredients, manages shopping lists
- **Kitchen Timer (Control Functions)**: Manages cooking sequences, handles interruptions
- **Recipe Book (Format Functions)**: Converts measurements, formats presentations

Just as a smart kitchen assistant uses various tools to help cook efficiently, pipeline functions provide the tools needed to create intelligent, adaptive CI/CD workflows.

## Expression Syntax

### Basic Expression Format

```yaml
# Variable reference
$(variableName)

# Compile-time expression (evaluated when pipeline is compiled)
${{ expression }}

# Runtime expression (evaluated during pipeline execution)
$[ expression ]

# Macro syntax (simple variable replacement)
$(variableName)
```

### Expression Context

```yaml
# Template expressions (compile-time)
${{ variables.myVariable }}

# Runtime expressions
$[variables.myVariable]

# Condition expressions
condition: and(succeeded(), eq(variables.deployToProduction, 'true'))
```

## Core Function Categories

### 1. String Functions

```yaml
variables:
  originalString: 'Hello Azure DevOps'
  branchName: 'refs/heads/feature/new-login'
  fileName: 'MyProject.Solution.dll'

steps:
# String length
- script: echo "Length: $[length(variables.originalString)]"  # Output: 17

# String contains
- script: echo "Contains 'Azure': $[contains(variables.originalString, 'Azure')]"  # Output: True

# String starts with
- script: echo "Is feature branch: $[startsWith(variables.branchName, 'refs/heads/feature/')]"  # Output: True

# String ends with
- script: echo "Is DLL file: $[endsWith(variables.fileName, '.dll')]"  # Output: True

# String replacement
- script: echo "Clean branch: $[replace(variables.branchName, 'refs/heads/', '')]"  # Output: feature/new-login

# String split
- script: echo "First part: $[split(variables.branchName, '/')[0]]"  # Output: refs

# Upper/Lower case
- script: |
    echo "Upper: $[upper(variables.originalString)]"  # Output: HELLO AZURE DEVOPS
    echo "Lower: $[lower(variables.originalString)]"  # Output: hello azure devops

# String formatting
- script: echo "Formatted: $[format('Build {0} on {1}', variables['Build.BuildNumber'], variables['Build.SourceBranch'])]"
```

### 2. Comparison and Logical Functions

```yaml
variables:
  buildNumber: '20231215.1'
  environment: 'production'
  isMainBranch: $[eq(variables['Build.SourceBranch'], 'refs/heads/main')]

steps:
# Equality
- script: echo "Is production: $[eq(variables.environment, 'production')]"  # Output: True

# Not equal
- script: echo "Not development: $[ne(variables.environment, 'development')]"  # Output: True

# Greater than / Less than
- script: echo "Build number > 20231201: $[gt(variables.buildNumber, '20231201.1')]"  # Output: True

# Logical AND
- script: echo "Production and main branch: $[and(eq(variables.environment, 'production'), variables.isMainBranch)]"

# Logical OR
- script: echo "Dev or staging: $[or(eq(variables.environment, 'development'), eq(variables.environment, 'staging'))]"

# Logical NOT
- script: echo "Not production: $[not(eq(variables.environment, 'production'))]"  # Output: False

# In operator (check if value is in a list)
- script: echo "Valid environment: $[in(variables.environment, 'development', 'staging', 'production')]"  # Output: True
```

### 3. Conversion Functions

```yaml
variables:
  stringNumber: '42'
  booleanValue: 'true'
  buildId: '12345'

steps:
# String conversion
- script: echo "As string: $[string(variables.buildId)]"

# Number conversion
- script: echo "As number: $[number(variables.stringNumber)]"  # Output: 42

# Boolean conversion
- script: echo "As boolean: $[bool(variables.booleanValue)]"  # Output: True

# JSON conversion
- script: echo "As JSON: $[join(',', 'item1', 'item2', 'item3')]"  # Output: item1,item2,item3
```

### 4. Array and Collection Functions

```yaml
variables:
  testProjects: '["UnitTests", "IntegrationTests", "E2ETests"]'
  environments: 'development,staging,production'

steps:
# Join arrays
- script: echo "Joined: $[join(';', 'item1', 'item2', 'item3')]"  # Output: item1;item2;item3

# Split strings into arrays
- script: echo "Split environments: $[split(variables.environments, ',')]"

# Array length
- script: echo "Project count: $[length(fromJson(variables.testProjects))]"  # Output: 3

# Check if array contains item
- script: echo "Has unit tests: $[contains(fromJson(variables.testProjects), 'UnitTests')]"  # Output: True

# Get array element by index
- script: echo "First project: $[fromJson(variables.testProjects)[0]]"  # Output: UnitTests
```

### 5. Date and Time Functions

```yaml
steps:
# Current date/time formatting
- script: echo "Current date: $[format('{0:yyyy-MM-dd}', pipeline.startTime)]"

- script: echo "Current time: $[format('{0:HH:mm:ss}', pipeline.startTime)]"

- script: echo "Custom format: $[format('{0:yyyy-MM-dd-HH-mm-ss}', pipeline.startTime)]"

# Date arithmetic
- script: echo "Tomorrow: $[format('{0:yyyy-MM-dd}', addDays(pipeline.startTime, 1))]"

- script: echo "Last week: $[format('{0:yyyy-MM-dd}', addDays(pipeline.startTime, -7))]"

# Day of week
- script: echo "Day of week: $[format('{0:dddd}', pipeline.startTime)]"

# Check if weekend
- script: echo "Is weekend: $[or(eq(format('{0:dddd}', pipeline.startTime), 'Saturday'), eq(format('{0:dddd}', pipeline.startTime), 'Sunday'))]"
```

### 6. Conditional Functions

```yaml
variables:
  deployToProduction: 'false'
  buildConfiguration: 'Release'

steps:
# If-then-else logic
- script: echo "Environment: $[if(eq(variables.deployToProduction, 'true'), 'Production', 'Development')]"

# Nested conditionals
- script: |
    echo "Build type: $[if(eq(variables.buildConfiguration, 'Release'), 
                         if(eq(variables.deployToProduction, 'true'), 'Production Release', 'Release'), 
                         'Debug')]"

# Coalesce (first non-empty value)
- script: echo "Value: $[coalesce(variables.customValue, variables.defaultValue, 'fallback')]"
```

## Comprehensive Example: Intelligent CI/CD Pipeline

```yaml
name: 'Smart-Pipeline-$(Date:yyyyMMdd)$(Rev:.r)'

trigger:
  branches:
    include:
    - main
    - develop
    - feature/*
    - release/*
    - hotfix/*

variables:
  # Dynamic variables using functions
  isMainBranch: $[eq(variables['Build.SourceBranch'], 'refs/heads/main')]
  isDevelopBranch: $[eq(variables['Build.SourceBranch'], 'refs/heads/develop')]
  isFeatureBranch: $[startsWith(variables['Build.SourceBranch'], 'refs/heads/feature/')]
  isReleaseBranch: $[startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')]
  isHotfixBranch: $[startsWith(variables['Build.SourceBranch'], 'refs/heads/hotfix/')]
  
  # Extract branch name without refs/heads/
  cleanBranchName: $[replace(variables['Build.SourceBranch'], 'refs/heads/', '')]
  
  # Determine environment based on branch
  targetEnvironment: $[if(variables.isMainBranch, 'production', 
                         if(variables.isDevelopBranch, 'staging', 
                            if(or(variables.isReleaseBranch, variables.isHotfixBranch), 'testing', 'development')))]
  
  # Build configuration based on branch
  buildConfiguration: $[if(or(variables.isMainBranch, variables.isReleaseBranch), 'Release', 'Debug')]
  
  # Version calculation
  majorVersion: '1'
  minorVersion: $[if(variables.isMainBranch, '0', '1')]
  patchVersion: $[if(variables.isHotfixBranch, variables['Build.BuildId'], '0')]
  semanticVersion: '$[format(''{0}.{1}.{2}', variables.majorVersion, variables.minorVersion, variables.patchVersion)]'
  
  # Deployment flags
  shouldDeploy: $[or(variables.isMainBranch, variables.isDevelopBranch, variables.isReleaseBranch, variables.isHotfixBranch)]
  shouldRunPerformanceTests: $[or(variables.isMainBranch, variables.isReleaseBranch)]
  shouldRunSecurityScan: $[or(variables.isMainBranch, variables.isReleaseBranch, variables.isHotfixBranch)]

stages:
- stage: BuildAndAnalyze
  displayName: 'Build and Code Analysis'
  jobs:
  - job: Build
    displayName: 'Build Application'
    pool:
      vmImage: 'ubuntu-latest'
    
    steps:
    - script: |
        echo "=== Pipeline Information ==="
        echo "Branch: $(cleanBranchName)"
        echo "Target Environment: $(targetEnvironment)"
        echo "Build Configuration: $(buildConfiguration)"
        echo "Semantic Version: $(semanticVersion)"
        echo "Should Deploy: $(shouldDeploy)"
        echo "=========================="
      displayName: 'Display pipeline information'

    - task: UseDotNet@2
      displayName: 'Install .NET SDK'
      inputs:
        version: '6.0.x'

    # Dynamic package restore with caching
    - task: Cache@2
      displayName: 'Cache NuGet packages'
      inputs:
        key: 'nuget | "$(Agent.OS)" | **/packages.lock.json,!**/bin/**,!**/obj/**'
        path: '$(NUGET_PACKAGES)'
        cacheHitVar: 'CACHE_RESTORED'

    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      condition: ne(variables.CACHE_RESTORED, 'true')
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    # Version stamping using functions
    - task: PowerShell@2
      displayName: 'Update version information'
      inputs:
        targetType: 'inline'
        script: |
          $version = "$(semanticVersion)"
          $buildDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
          $branch = "$(cleanBranchName)"
          
          Write-Host "Setting version to: $version"
          
          # Update AssemblyInfo or Directory.Build.props
          $content = @"
          <Project>
            <PropertyGroup>
              <Version>$version</Version>
              <AssemblyVersion>$version</AssemblyVersion>
              <FileVersion>$version</FileVersion>
              <BuildDate>$buildDate</BuildDate>
              <SourceBranch>$branch</SourceBranch>
            </PropertyGroup>
          </Project>
          "@
          
          $content | Out-File -FilePath "Directory.Build.props" -Encoding UTF8

    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore /p:Version=$(semanticVersion)'

    # Conditional code analysis
    - task: SonarCloudPrepare@1
      displayName: 'Prepare SonarCloud analysis'
      condition: eq(variables.shouldRunSecurityScan, true)
      inputs:
        SonarCloud: 'SonarCloud-Connection'
        organization: 'my-org'
        scannerMode: 'MSBuild'
        projectKey: 'my-project'
        projectName: 'My Project'
        projectVersion: '$(semanticVersion)'

    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage" --logger trx'

    - task: SonarCloudAnalyze@1
      displayName: 'Run SonarCloud analysis'
      condition: eq(variables.shouldRunSecurityScan, true)

    - task: SonarCloudPublish@1
      displayName: 'Publish SonarCloud results'
      condition: eq(variables.shouldRunSecurityScan, true)

    # Dynamic artifact creation
    - task: DotNetCoreCLI@2
      displayName: 'Create deployable package'
      condition: eq(variables.shouldDeploy, true)
      inputs:
        command: 'publish'
        publishWebProjects: true
        arguments: '--configuration $(buildConfiguration) --no-build --output $(Build.ArtifactStagingDirectory) /p:Version=$(semanticVersion)'

    - task: PublishBuildArtifacts@1
      displayName: 'Publish build artifacts'
      condition: eq(variables.shouldDeploy, true)
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop-$(targetEnvironment)'

- stage: QualityGates
  displayName: 'Quality Gates and Testing'
  dependsOn: BuildAndAnalyze
  condition: succeeded()
  jobs:
  
  # Performance tests with conditional execution
  - job: PerformanceTests
    displayName: 'Performance Testing'
    condition: eq(variables.shouldRunPerformanceTests, true)
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - script: |
        echo "Running performance tests for $(targetEnvironment)"
        echo "Test duration: $[if(eq(variables.targetEnvironment, 'production'), '30', '10')] minutes"
      displayName: 'Performance test configuration'

    - task: PowerShell@2
      displayName: 'Execute performance tests'
      inputs:
        targetType: 'inline'
        script: |
          $testDuration = if ("$(targetEnvironment)" -eq "production") { 30 } else { 10 }
          $thresholdCpu = if ("$(targetEnvironment)" -eq "production") { 70 } else { 80 }
          $thresholdMemory = if ("$(targetEnvironment)" -eq "production") { 80 } else { 85 }
          
          Write-Host "Performance test settings:"
          Write-Host "  Duration: $testDuration minutes"
          Write-Host "  CPU Threshold: $thresholdCpu%"
          Write-Host "  Memory Threshold: $thresholdMemory%"
          
          # Simulate performance testing
          Write-Host "Running performance tests..."
          Start-Sleep -Seconds 30
          Write-Host "Performance tests completed successfully"

  # Security scanning with smart triggering
  - job: SecurityScan
    displayName: 'Security Scanning'
    condition: eq(variables.shouldRunSecurityScan, true)
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - script: |
        scanLevel="$[if(variables.isMainBranch, 'comprehensive', 'standard')]"
        echo "Security scan level: $scanLevel"
        echo "Compliance check: $[if(or(variables.isMainBranch, variables.isReleaseBranch), 'required', 'optional')]"
      displayName: 'Security scan configuration'

    - task: PowerShell@2
      displayName: 'Run security scans'
      inputs:
        targetType: 'inline'
        script: |
          $scanLevel = if ($env:IS_MAIN_BRANCH -eq "True") { "comprehensive" } else { "standard" }
          Write-Host "Running $scanLevel security scan..."
          
          # Simulate different scan types
          if ($scanLevel -eq "comprehensive") {
            Write-Host "- SAST (Static Application Security Testing)"
            Write-Host "- DAST (Dynamic Application Security Testing)"
            Write-Host "- Dependency vulnerability scan"
            Write-Host "- Container security scan"
          } else {
            Write-Host "- Basic SAST scan"
            Write-Host "- Dependency vulnerability scan"
          }
          
          Start-Sleep -Seconds 45
          Write-Host "Security scans completed successfully"
      env:
        IS_MAIN_BRANCH: $(isMainBranch)

- stage: Deploy
  displayName: 'Deploy to $(targetEnvironment)'
  dependsOn: 
  - BuildAndAnalyze
  - QualityGates
  condition: and(succeeded(), eq(variables.shouldDeploy, true))
  jobs:
  
  - deployment: DeployApplication
    displayName: 'Deploy to $(targetEnvironment)'
    pool:
      vmImage: 'ubuntu-latest'
    environment: '$(targetEnvironment)'
    
    variables:
      # Environment-specific settings using functions
      appServiceName: '$[format(''myapp-{0}'', variables.targetEnvironment)]'
      resourceGroup: '$[format(''rg-myapp-{0}'', variables.targetEnvironment)]'
      deploymentSlot: '$[if(eq(variables.targetEnvironment, ''production''), ''staging'', ''main'')]'
      healthCheckUrl: '$[format(''https://{0}.azurewebsites.net/health'', variables.appServiceName)]'
      notificationChannel: '$[if(eq(variables.targetEnvironment, ''production''), ''#alerts'', ''#dev-notifications'')]'
    
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: 'drop-$(targetEnvironment)'

          - script: |
              echo "=== Deployment Configuration ==="
              echo "Environment: $(targetEnvironment)"
              echo "App Service: $(appServiceName)"
              echo "Resource Group: $(resourceGroup)"
              echo "Deployment Slot: $(deploymentSlot)"
              echo "Health Check URL: $(healthCheckUrl)"
              echo "Version: $(semanticVersion)"
              echo "==============================="
            displayName: 'Display deployment configuration'

          # Environment-specific pre-deployment steps
          - task: PowerShell@2
            displayName: 'Pre-deployment validation'
            inputs:
              targetType: 'inline'
              script: |
                $environment = "$(targetEnvironment)"
                $checks = @()
                
                switch ($environment) {
                  "production" {
                    $checks += "Database backup verification"
                    $checks += "Blue-green deployment readiness"
                    $checks += "Rollback plan validation"
                    $checks += "Load balancer configuration"
                  }
                  "staging" {
                    $checks += "Database migration preview"
                    $checks += "Integration endpoints health"
                    $checks += "Test data preparation"
                  }
                  default {
                    $checks += "Environment cleanup"
                    $checks += "Test database reset"
                  }
                }
                
                Write-Host "Pre-deployment checks for $environment:"
                foreach ($check in $checks) {
                  Write-Host "  ✓ $check"
                  Start-Sleep -Seconds 2
                }

          - task: AzureWebApp@1
            displayName: 'Deploy to Azure App Service'
            inputs:
              azureSubscription: 'Azure-$(targetEnvironment)-Connection'
              appType: 'webApp'
              appName: '$(appServiceName)'
              package: '$(Pipeline.Workspace)/drop-$(targetEnvironment)/**/*.zip'
              deploymentMethod: 'zipDeploy'
              appSettings: |
                -Version "$(semanticVersion)"
                -Environment "$(targetEnvironment)"
                -BuildId "$(Build.BuildId)"
                -SourceBranch "$(cleanBranchName)"
                -DeploymentTime "$[format('{0:yyyy-MM-dd HH:mm:ss} UTC', pipeline.startTime)]"

          # Smart health check with retry logic
          - task: PowerShell@2
            displayName: 'Health check with smart retry'
            inputs:
              targetType: 'inline'
              script: |
                $url = "$(healthCheckUrl)"
                $environment = "$(targetEnvironment)"
                
                # Environment-specific retry configuration
                $config = switch ($environment) {
                  "production" { @{ MaxAttempts = 10; DelaySeconds = 30; TimeoutSeconds = 60 } }
                  "staging"    { @{ MaxAttempts = 8;  DelaySeconds = 20; TimeoutSeconds = 45 } }
                  default      { @{ MaxAttempts = 5;  DelaySeconds = 15; TimeoutSeconds = 30 } }
                }
                
                Write-Host "Health check configuration for $environment :"
                Write-Host "  Max attempts: $($config.MaxAttempts)"
                Write-Host "  Delay between attempts: $($config.DelaySeconds) seconds"
                Write-Host "  Request timeout: $($config.TimeoutSeconds) seconds"
                
                $attempt = 1
                do {
                  try {
                    Write-Host "Attempt $attempt of $($config.MaxAttempts) - Testing $url"
                    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec $config.TimeoutSeconds
                    
                    if ($response.StatusCode -eq 200) {
                      Write-Host "✅ Health check passed! Status: $($response.StatusCode)"
                      
                      # Parse response for additional validation
                      if ($response.Content -match '"status":\s*"healthy"') {
                        Write-Host "✅ Application reports healthy status"
                      }
                      if ($response.Content -match '"version":\s*"$(semanticVersion)"') {
                        Write-Host "✅ Correct version deployed: $(semanticVersion)"
                      }
                      
                      exit 0
                    }
                  } catch {
                    Write-Warning "Attempt $attempt failed: $($_.Exception.Message)"
                  }
                  
                  if ($attempt -eq $config.MaxAttempts) {
                    Write-Error "❌ Health check failed after $($config.MaxAttempts) attempts"
                    exit 1
                  }
                  
                  $attempt++
                  Write-Host "Waiting $($config.DelaySeconds) seconds before next attempt..."
                  Start-Sleep -Seconds $config.DelaySeconds
                } while ($attempt -le $config.MaxAttempts)

          # Smart notification based on environment and result
          - task: PowerShell@2
            displayName: 'Send deployment notification'
            condition: always()
            inputs:
              targetType: 'inline'
              script: |
                $environment = "$(targetEnvironment)"
                $version = "$(semanticVersion)"
                $branch = "$(cleanBranchName)"
                $buildId = "$(Build.BuildId)"
                $channel = "$(notificationChannel)"
                
                $status = if ($env:AGENT_JOBSTATUS -eq "Succeeded") { "✅ SUCCESS" } else { "❌ FAILED" }
                $color = if ($env:AGENT_JOBSTATUS -eq "Succeeded") { "good" } else { "danger" }
                
                $message = @"
                $status Deployment to $environment
                
                📦 **Version:** $version
                🌿 **Branch:** $branch  
                🏗️ **Build:** $buildId
                🎯 **Environment:** $environment
                ⏰ **Time:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
                
                $(if ($env:AGENT_JOBSTATUS -eq "Succeeded") { 
                  "🔗 **URL:** https://$(appServiceName).azurewebsites.net" 
                } else { 
                  "📋 **Logs:** https://dev.azure.com/$(System.TeamFoundationCollectionUri)/$(System.TeamProject)/_build/results?buildId=$buildId" 
                })
                "@
                
                Write-Host "Notification:"
                Write-Host $message
                Write-Host "Channel: $channel"
                
                # Here you would integrate with your notification system
                # (Slack, Teams, email, etc.)
```

## Advanced Function Patterns

### 1. Complex String Manipulation

```yaml
variables:
  commitMessage: 'feat(auth): add OAuth2 integration for GitHub (#123)'
  
steps:
- script: |
    # Extract feature type
    featureType="${commitMessage#*(}"
    featureType="${featureType%%)*}"
    echo "Feature type: $featureType"
    
    # Extract PR number
    prNumber=$(echo "$commitMessage" | grep -o '#[0-9]*' | tr -d '#')
    echo "PR number: $prNumber"
  env:
    commitMessage: $[variables['Build.SourceVersionMessage']]
```

### 2. Dynamic JSON Processing

```yaml
variables:
  environmentConfig: |
    {
      "development": {"instances": 1, "sku": "B1"},
      "staging": {"instances": 2, "sku": "S1"},
      "production": {"instances": 5, "sku": "P1v2"}
    }

steps:
- script: |
    config='$(environmentConfig)'
    environment="$(targetEnvironment)"
    instances=$(echo $config | jq -r ".[\"$environment\"].instances")
    sku=$(echo $config | jq -r ".[\"$environment\"].sku")
    
    echo "Environment: $environment"
    echo "Instances: $instances"
    echo "SKU: $sku"
  displayName: 'Parse environment configuration'
```

### 3. Mathematical Calculations

```yaml
variables:
  baseTimeout: 300  # 5 minutes
  complexityFactor: 2
  
steps:
- script: |
    timeout=$[mul(variables.baseTimeout, variables.complexityFactor)]
    echo "Calculated timeout: $timeout seconds"
    echo "##vso[task.setvariable variable=calculatedTimeout]$timeout"
```

### 4. Smart Dependency Resolution

```yaml
parameters:
- name: services
  type: object
  default:
  - name: 'api'
    dependencies: ['database']
  - name: 'web'
    dependencies: ['api']
  - name: 'database'
    dependencies: []

jobs:
- ${{ each service in parameters.services }}:
  - job: Deploy_${{ service.name }}
    ${{ if gt(length(service.dependencies), 0) }}:
      dependsOn:
      - ${{ each dep in service.dependencies }}:
        - Deploy_${{ dep }}
    steps:
    - script: echo "Deploying ${{ service.name }}"
```

## Best Practices

### 1. Use Appropriate Expression Types

```yaml
# Compile-time (template) expressions for static values
${{ variables.staticValue }}

# Runtime expressions for dynamic values
$[variables.runtimeValue]

# Macro syntax for simple variable substitution
$(simpleVariable)
```

### 2. Keep Complex Logic Readable

```yaml
# Good: Break complex expressions into variables
variables:
  isMainOrRelease: $[or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/'))]
  shouldDeploy: $[and(succeeded(), variables.isMainOrRelease)]

# Avoid: Overly complex inline expressions
condition: $[and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')))]
```

### 3. Handle Edge Cases

```yaml
# Use coalesce for fallback values
deploymentTimeout: $[coalesce(variables.customTimeout, '600')]

# Validate inputs
condition: and(succeeded(), ne(variables.requiredVariable, ''))

# Handle null/empty values
safeValue: $[if(eq(variables.maybeEmpty, ''), 'default', variables.maybeEmpty)]
```

### 4. Document Complex Functions

```yaml
variables:
  # Calculate semantic version based on branch type and build number
  # Main branch: 1.0.{BuildId}
  # Release branch: 1.1.{BuildId}  
  # Other branches: 1.2.{BuildId}-preview
  semanticVersion: $[format('{0}.{1}.{2}{3}', 
                     '1',
                     if(eq(variables['Build.SourceBranch'], 'refs/heads/main'), '0', 
                        if(startsWith(variables['Build.SourceBranch'], 'refs/heads/release/'), '1', '2')),
                     variables['Build.BuildId'],
                     if(or(eq(variables['Build.SourceBranch'], 'refs/heads/main'), 
                           startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')), '', '-preview'))]
```

## Common Function Reference

| Category | Function | Example | Description |
|----------|----------|---------|-------------|
| **String** | `contains(string, substring)` | `contains(variables.branch, 'feature')` | Check if string contains substring |
| | `startsWith(string, prefix)` | `startsWith(variables.branch, 'refs/heads/')` | Check if string starts with prefix |
| | `endsWith(string, suffix)` | `endsWith(variables.file, '.json')` | Check if string ends with suffix |
| | `replace(string, old, new)` | `replace(variables.path, '\\', '/')` | Replace all occurrences |
| | `format(template, args...)` | `format('v{0}.{1}', major, minor)` | Format string with arguments |
| **Logic** | `and(expr1, expr2)` | `and(succeeded(), eq(variables.deploy, 'true'))` | Logical AND |
| | `or(expr1, expr2)` | `or(failed(), canceled())` | Logical OR |
| | `not(expr)` | `not(eq(variables.skip, 'true'))` | Logical NOT |
| **Comparison** | `eq(value1, value2)` | `eq(variables.env, 'prod')` | Equality |
| | `ne(value1, value2)` | `ne(variables.version, '')` | Not equal |
| | `gt(value1, value2)` | `gt(variables.count, 5)` | Greater than |
| | `ge(value1, value2)` | `ge(variables.score, 80)` | Greater than or equal |
| **Conversion** | `string(value)` | `string(variables.number)` | Convert to string |
| | `number(value)` | `number(variables.stringNum)` | Convert to number |
| | `bool(value)` | `bool(variables.flag)` | Convert to boolean |
| **Array** | `join(separator, items...)` | `join(',', 'a', 'b', 'c')` | Join items with separator |
| | `split(string, separator)` | `split(variables.list, ',')` | Split string into array |
| | `length(collection)` | `length(variables.items)` | Get collection length |
| **Date** | `format(template, date)` | `format('{0:yyyy-MM-dd}', pipeline.startTime)` | Format date |
| | `addDays(date, days)` | `addDays(pipeline.startTime, 7)` | Add days to date |

Functions and expressions are the intelligence layer of your Azure DevOps pipelines, enabling sophisticated decision-making and dynamic behavior that adapts to your specific requirements and conditions.
