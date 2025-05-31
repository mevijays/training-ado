# Azure DevOps Pipeline Loops and Matrix Strategies

## Overview

Loops and matrix strategies in Azure DevOps pipelines allow you to run jobs or steps multiple times with different parameter sets. This powerful feature enables you to test across multiple configurations, deploy to multiple environments, or process multiple items efficiently without duplicating pipeline code.

## Understanding Loops and Matrix

Matrix strategies create multiple parallel jobs from a single job definition, each with different variable values. This is particularly useful for testing across multiple platforms, versions, or configurations.

### Analogy: Assembly Line Production

Think of matrix strategies like a sophisticated manufacturing assembly line:

- **Blueprint (Job Definition)**: Your job template that defines what needs to be built
- **Production Variants**: Different models/configurations (like different OS versions, browser types)
- **Parallel Assembly Lines**: Multiple matrix jobs running simultaneously
- **Quality Control Stations**: Each variant goes through the same process but with different specifications
- **Factory Floor Manager**: Azure DevOps orchestrating all the parallel production lines
- **Final Inspection**: Collecting results from all variants before proceeding

Just as a factory can produce multiple variants of a product simultaneously using the same process, matrix strategies let you run the same job logic across multiple configurations in parallel.

## Matrix Strategy Fundamentals

### Basic Matrix Syntax

```yaml
strategy:
  matrix:
    configurationName1:
      variableName1: value1
      variableName2: value2
    configurationName2:
      variableName1: value3
      variableName2: value4
  maxParallel: 2  # Optional: limit concurrent jobs
```

### Simple Matrix Example

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

strategy:
  matrix:
    Python38:
      pythonVersion: '3.8'
    Python39:
      pythonVersion: '3.9'
    Python310:
      pythonVersion: '3.10'
  maxParallel: 3

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '$(pythonVersion)'
  displayName: 'Use Python $(pythonVersion)'

- script: |
    python -m pip install --upgrade pip
    pip install pytest
  displayName: 'Install dependencies'

- script: |
    pytest tests/ --junitxml=junit/test-results-$(pythonVersion).xml
  displayName: 'Run tests'

- task: PublishTestResults@2
  inputs:
    testResultsFiles: 'junit/test-results-$(pythonVersion).xml'
    testRunTitle: 'Python $(pythonVersion) Tests'
  condition: always()
```

## Comprehensive Example: Cross-Platform Testing Pipeline

```yaml
name: 'Cross-Platform-CI-$(Date:yyyyMMdd)-$(Rev:r)'

trigger:
  branches:
    include:
    - main
    - develop
    - feature/*
  paths:
    include:
    - src/
    - tests/
    exclude:
    - docs/

variables:
  buildConfiguration: 'Release'
  dotnetVersion: '6.0.x'

stages:
- stage: BuildAndTest
  displayName: 'Build and Test Across Platforms'
  jobs:
  
  # Matrix job for different operating systems
  - job: CrossPlatformTests
    displayName: 'Cross-Platform Testing'
    strategy:
      matrix:
        Linux:
          imageName: 'ubuntu-latest'
          osType: 'Linux'
        Windows:
          imageName: 'windows-latest'
          osType: 'Windows'
        macOS:
          imageName: 'macOS-latest'
          osType: 'macOS'
      maxParallel: 3
    
    pool:
      vmImage: $(imageName)
    
    steps:
    - task: UseDotNet@2
      displayName: 'Install .NET $(dotnetVersion)'
      inputs:
        version: $(dotnetVersion)
        includePreviewVersions: false

    - task: DotNetCoreCLI@2
      displayName: 'Restore NuGet packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
        verbosityRestore: 'Minimal'

    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage" --logger trx --results-directory $(Common.TestResultsDirectory)'

    - task: PublishTestResults@2
      displayName: 'Publish test results'
      condition: always()
      inputs:
        testRunner: 'VSTest'
        testResultsFiles: '$(Common.TestResultsDirectory)/*.trx'
        testRunTitle: '$(osType) - Unit Tests'
        mergeTestResults: true

    # OS-specific tasks
    - bash: |
        echo "Running on Linux/macOS"
        chmod +x scripts/setup.sh
        ./scripts/setup.sh
      displayName: 'Run Unix setup script'
      condition: ne(variables.osType, 'Windows')

    - powershell: |
        Write-Host "Running on Windows"
        .\scripts\setup.ps1
      displayName: 'Run Windows setup script'
      condition: eq(variables.osType, 'Windows')

  # Matrix job for different .NET versions
  - job: MultiVersionTests
    displayName: 'Multi-Version .NET Testing'
    dependsOn: CrossPlatformTests
    condition: succeeded()
    
    pool:
      vmImage: 'ubuntu-latest'
    
    strategy:
      matrix:
        DotNet6:
          dotnetTestVersion: '6.0.x'
          frameworkVersion: 'net6.0'
        DotNet7:
          dotnetTestVersion: '7.0.x'
          frameworkVersion: 'net7.0'
        DotNet8:
          dotnetTestVersion: '8.0.x'
          frameworkVersion: 'net8.0'
      maxParallel: 2
    
    steps:
    - task: UseDotNet@2
      displayName: 'Install .NET $(dotnetTestVersion)'
      inputs:
        version: $(dotnetTestVersion)
        includePreviewVersions: true

    - task: DotNetCoreCLI@2
      displayName: 'Build for $(frameworkVersion)'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--framework $(frameworkVersion) --configuration $(buildConfiguration)'

    - task: DotNetCoreCLI@2
      displayName: 'Test on $(frameworkVersion)'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--framework $(frameworkVersion) --configuration $(buildConfiguration) --logger trx --results-directory $(Common.TestResultsDirectory)'

    - task: PublishTestResults@2
      displayName: 'Publish .NET $(dotnetTestVersion) results'
      condition: always()
      inputs:
        testRunner: 'VSTest'
        testResultsFiles: '$(Common.TestResultsDirectory)/*.trx'
        testRunTitle: '.NET $(dotnetTestVersion) - Compatibility Tests'

- stage: BrowserTesting
  displayName: 'Browser Compatibility Testing'
  dependsOn: BuildAndTest
  condition: succeeded()
  jobs:
  
  # Matrix for browser testing
  - job: SeleniumTests
    displayName: 'Selenium Browser Tests'
    
    pool:
      vmImage: 'ubuntu-latest'
    
    strategy:
      matrix:
        Chrome:
          browserName: 'chrome'
          browserDisplayName: 'Google Chrome'
        Firefox:
          browserName: 'firefox'
          browserDisplayName: 'Mozilla Firefox'
        Edge:
          browserName: 'edge'
          browserDisplayName: 'Microsoft Edge'
      maxParallel: 3
    
    steps:
    - task: UseDotNet@2
      inputs:
        version: $(dotnetVersion)

    - task: DotNetCoreCLI@2
      displayName: 'Restore test project'
      inputs:
        command: 'restore'
        projects: '**/WebTests.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build test project'
      inputs:
        command: 'build'
        projects: '**/WebTests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    # Install browser drivers
    - script: |
        case "$(browserName)" in
          "chrome")
            # Install Chrome and ChromeDriver
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
            sudo apt-get update
            sudo apt-get install -y google-chrome-stable
            ;;
          "firefox")
            # Install Firefox and GeckoDriver
            sudo apt-get update
            sudo apt-get install -y firefox
            ;;
          "edge")
            # Install Edge
            curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
            sudo apt-get update
            sudo apt-get install -y microsoft-edge-stable
            ;;
        esac
      displayName: 'Install $(browserDisplayName)'

    - task: DotNetCoreCLI@2
      displayName: 'Run Selenium tests on $(browserDisplayName)'
      inputs:
        command: 'test'
        projects: '**/WebTests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --logger trx --results-directory $(Common.TestResultsDirectory)'
      env:
        BROWSER: $(browserName)
        SELENIUM_BROWSER: $(browserName)

    - task: PublishTestResults@2
      displayName: 'Publish $(browserDisplayName) test results'
      condition: always()
      inputs:
        testRunner: 'VSTest'
        testResultsFiles: '$(Common.TestResultsDirectory)/*.trx'
        testRunTitle: '$(browserDisplayName) - UI Tests'

    # Capture screenshots on failure
    - task: PublishBuildArtifacts@1
      displayName: 'Publish test screenshots'
      condition: failed()
      inputs:
        pathToPublish: 'WebTests/Screenshots'
        artifactName: 'Screenshots-$(browserName)'

- stage: DeploymentMatrix
  displayName: 'Multi-Environment Deployment'
  dependsOn: 
  - BuildAndTest
  - BrowserTesting
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  
  # Matrix for deploying to multiple environments
  - deployment: DeployToEnvironments
    displayName: 'Deploy to Multiple Environments'
    
    strategy:
      matrix:
        Development:
          environmentName: 'development'
          resourceGroup: 'rg-myapp-dev'
          appServiceName: 'myapp-dev'
          connectionString: $(DevConnectionString)
        Staging:
          environmentName: 'staging'
          resourceGroup: 'rg-myapp-staging'
          appServiceName: 'myapp-staging'
          connectionString: $(StagingConnectionString)
        Testing:
          environmentName: 'testing'
          resourceGroup: 'rg-myapp-test'
          appServiceName: 'myapp-test'
          connectionString: $(TestConnectionString)
      maxParallel: 2
    
    pool:
      vmImage: 'ubuntu-latest'
    
    environment: $(environmentName)
    
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: drop

          - task: AzureResourceManagerTemplateDeployment@3
            displayName: 'Deploy ARM template to $(environmentName)'
            inputs:
              deploymentScope: 'Resource Group'
              azureResourceManagerConnection: 'Azure-$(environmentName)-Connection'
              subscriptionId: $(AzureSubscriptionId)
              action: 'Create Or Update Resource Group'
              resourceGroupName: $(resourceGroup)
              location: 'East US'
              templateLocation: 'Linked artifact'
              csmFile: '$(Pipeline.Workspace)/drop/infrastructure/main.json'
              csmParametersFile: '$(Pipeline.Workspace)/drop/infrastructure/parameters-$(environmentName).json'

          - task: AzureWebApp@1
            displayName: 'Deploy to $(appServiceName)'
            inputs:
              azureSubscription: 'Azure-$(environmentName)-Connection'
              appType: 'webApp'
              appName: $(appServiceName)
              package: '$(Pipeline.Workspace)/drop/**/*.zip'
              appSettings: |
                -ConnectionStrings:DefaultConnection "$(connectionString)"
                -Environment:Name "$(environmentName)"

          - task: PowerShell@2
            displayName: 'Smoke test $(environmentName)'
            inputs:
              targetType: 'inline'
              script: |
                $maxAttempts = 5
                $attempt = 1
                $url = "https://$(appServiceName).azurewebsites.net/health"
                
                do {
                  try {
                    Write-Host "Attempt $attempt - Testing $url"
                    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
                    if ($response.StatusCode -eq 200) {
                      Write-Host "✅ Health check passed for $(environmentName)"
                      break
                    }
                  } catch {
                    Write-Warning "Attempt $attempt failed: $($_.Exception.Message)"
                  }
                  
                  if ($attempt -eq $maxAttempts) {
                    Write-Error "❌ Health check failed for $(environmentName) after $maxAttempts attempts"
                    exit 1
                  }
                  
                  $attempt++
                  Start-Sleep -Seconds 30
                } while ($attempt -le $maxAttempts)

- stage: DatabaseMigration
  displayName: 'Database Migration Matrix'
  dependsOn: DeploymentMatrix
  condition: succeeded()
  jobs:
  
  # Matrix for database operations
  - job: MigrateDatabase
    displayName: 'Database Migration'
    
    pool:
      vmImage: 'ubuntu-latest'
    
    strategy:
      matrix:
        Development:
          environmentName: 'development'
          dbConnectionString: $(DevDbConnectionString)
          migrationLevel: 'all'
        Staging:
          environmentName: 'staging'
          dbConnectionString: $(StagingDbConnectionString)
          migrationLevel: 'structural'
        Testing:
          environmentName: 'testing'
          dbConnectionString: $(TestDbConnectionString)
          migrationLevel: 'all'
      maxParallel: 1  # Run database migrations sequentially for safety
    
    steps:
    - task: UseDotNet@2
      inputs:
        version: $(dotnetVersion)

    - task: DotNetCoreCLI@2
      displayName: 'Install EF Core tools'
      inputs:
        command: 'custom'
        custom: 'tool'
        arguments: 'install --global dotnet-ef'

    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/DataAccess.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Run database migrations for $(environmentName)'
      inputs:
        command: 'custom'
        custom: 'ef'
        arguments: 'database update --project DataAccess --connection "$(dbConnectionString)"'

    # Conditional data seeding based on environment
    - task: PowerShell@2
      displayName: 'Seed test data'
      condition: ne(variables.environmentName, 'production')
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Seeding test data for $(environmentName)"
          # Add data seeding logic here
          dotnet run --project DataSeeder -- --environment $(environmentName) --connection "$(dbConnectionString)"

    - task: PowerShell@2
      displayName: 'Validate database schema'
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Validating database schema for $(environmentName)"
          # Add schema validation logic
          dotnet run --project SchemaValidator -- --connection "$(dbConnectionString)"
```

## Advanced Matrix Patterns

### 1. Conditional Matrix Execution

```yaml
jobs:
- job: ConditionalMatrix
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
  strategy:
    matrix:
      ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
        Production:
          environment: 'prod'
      ${{ if ne(variables['Build.SourceBranch'], 'refs/heads/main') }}:
        Development:
          environment: 'dev'
        Testing:
          environment: 'test'
```

### 2. Dynamic Matrix from Variables

```yaml
variables:
  environments: '["dev", "staging", "prod"]'
  
jobs:
- job: DynamicMatrix
  strategy:
    matrix:
      ${{ each env in fromJson(variables.environments) }}:
        ${{ env }}:
          environmentName: ${{ env }}
          resourceGroup: 'rg-myapp-${{ env }}'
```

### 3. Nested Matrix Strategies

```yaml
# Use multiple jobs with different matrix strategies
jobs:
- job: UnitTests
  strategy:
    matrix:
      Windows_Net6:
        imageName: 'windows-latest'
        dotnetVersion: '6.0.x'
      Linux_Net6:
        imageName: 'ubuntu-latest'
        dotnetVersion: '6.0.x'
      Windows_Net7:
        imageName: 'windows-latest'
        dotnetVersion: '7.0.x'

- job: IntegrationTests
  dependsOn: UnitTests
  strategy:
    matrix:
      SqlServer:
        dbType: 'sqlserver'
        connectionString: $(SqlServerConnection)
      PostgreSQL:
        dbType: 'postgresql'
        connectionString: $(PostgreSqlConnection)
```

### 4. Matrix with Custom Variables

```yaml
variables:
  matrix.linux: |
    {
      "Ubuntu20": {
        "vmImage": "ubuntu-20.04",
        "osName": "Ubuntu 20.04"
      },
      "Ubuntu22": {
        "vmImage": "ubuntu-22.04", 
        "osName": "Ubuntu 22.04"
      }
    }

jobs:
- job: CustomMatrix
  strategy:
    matrix: ${{ fromJson(variables['matrix.linux']) }}
  pool:
    vmImage: $(vmImage)
  steps:
  - script: echo "Running on $(osName)"
```

## Loop Patterns with Each

### 1. Template Parameters Loop

```yaml
# File: templates/deploy-template.yml
parameters:
- name: environments
  type: object
  default: []

jobs:
- ${{ each environment in parameters.environments }}:
  - deployment: Deploy_${{ environment.name }}
    environment: ${{ environment.name }}
    pool:
      vmImage: 'ubuntu-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo "Deploying to ${{ environment.name }}"
          - script: echo "Using resource group ${{ environment.resourceGroup }}"
```

```yaml
# Main pipeline file
extends:
  template: templates/deploy-template.yml
  parameters:
    environments:
    - name: 'development'
      resourceGroup: 'rg-dev'
    - name: 'staging'
      resourceGroup: 'rg-staging'
    - name: 'production'
      resourceGroup: 'rg-prod'
```

### 2. Dynamic Step Generation

```yaml
variables:
  testProjects: |
    [
      {"name": "UnitTests", "path": "tests/unit"},
      {"name": "IntegrationTests", "path": "tests/integration"},
      {"name": "E2ETests", "path": "tests/e2e"}
    ]

steps:
- ${{ each project in fromJson(variables.testProjects) }}:
  - task: DotNetCoreCLI@2
    displayName: 'Run ${{ project.name }}'
    inputs:
      command: 'test'
      projects: '${{ project.path }}/**/*.csproj'
      arguments: '--logger trx --results-directory $(Common.TestResultsDirectory)/${{ project.name }}'
```

## Best Practices

### 1. Optimize Matrix Execution

```yaml
# Good: Use maxParallel to control resource usage
strategy:
  matrix:
    config1: {...}
    config2: {...}
    config3: {...}
  maxParallel: 2  # Don't overwhelm the system

# Good: Group similar configurations
strategy:
  matrix:
    FastTests:
      testSuite: 'unit'
      timeout: '5m'
    SlowTests:
      testSuite: 'integration'
      timeout: '30m'
```

### 2. Handle Matrix Failures Gracefully

```yaml
jobs:
- job: MatrixTests
  continueOnError: true  # Don't fail entire pipeline if one matrix job fails
  strategy:
    matrix:
      config1: {...}
      config2: {...}
  steps:
  - script: |
      # Your test logic
      echo "Running tests for $(configuration)"
    continueOnError: true  # Continue with other matrix jobs
```

### 3. Use Meaningful Matrix Names

```yaml
# Good: Descriptive matrix names
strategy:
  matrix:
    Windows_Net6_Chrome:
      os: 'windows-latest'
      dotnet: '6.0.x'
      browser: 'chrome'
    Linux_Net7_Firefox:
      os: 'ubuntu-latest'
      dotnet: '7.0.x'
      browser: 'firefox'

# Avoid: Generic names
strategy:
  matrix:
    config1: {...}
    config2: {...}
```

### 4. Share Common Variables

```yaml
variables:
  commonDotNetVersion: '6.0.x'
  commonBuildConfiguration: 'Release'

jobs:
- job: MatrixJob
  strategy:
    matrix:
      Windows:
        vmImage: 'windows-latest'
        dotnetVersion: $(commonDotNetVersion)
      Linux:
        vmImage: 'ubuntu-latest'
        dotnetVersion: $(commonDotNetVersion)
```

## Troubleshooting Matrix Issues

### 1. Debug Matrix Variables

```yaml
steps:
- script: |
    echo "Matrix variables:"
    echo "vmImage: $(vmImage)"
    echo "dotnetVersion: $(dotnetVersion)"
    echo "All variables:"
    env | sort
  displayName: 'Debug matrix configuration'
```

### 2. Handle Matrix Dependencies

```yaml
jobs:
- job: Build
  steps:
  - script: echo "Building application"

- job: TestMatrix
  dependsOn: Build
  condition: succeeded()  # Only run if build succeeded
  strategy:
    matrix:
      config1: {...}
      config2: {...}
```

### 3. Collect Matrix Results

```yaml
- job: CollectResults
  dependsOn: TestMatrix
  condition: always()  # Run regardless of matrix results
  steps:
  - script: |
      echo "Matrix job results:"
      echo "config1: ${{ dependencies.TestMatrix.outputs['config1.result'] }}"
      echo "config2: ${{ dependencies.TestMatrix.outputs['config2.result'] }}"
```

Matrix strategies and loops are essential for efficient, scalable CI/CD pipelines. They allow you to test comprehensively across multiple configurations while maintaining clean, maintainable pipeline code.
