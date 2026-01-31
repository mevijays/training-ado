# Azure DevOps Tasks and Custom Task Development

## Overview

Tasks are the fundamental building blocks of Azure DevOps pipelines. They represent discrete units of work that perform specific operations like building code, running tests, deploying applications, or executing custom scripts. Azure DevOps provides hundreds of built-in tasks, and you can also create custom tasks to meet specific requirements.

## Understanding Tasks

Tasks encapsulate reusable functionality with defined inputs, outputs, and execution logic. They abstract complex operations into simple, configurable components that can be easily shared across pipelines and teams.

### Analogy: Professional Tool Workshop

Think of Azure DevOps tasks like a well-organized professional workshop with specialized tools:

- **Power Tools (Built-in Tasks)**: Professional-grade tools like table saws, drill presses, sanders - ready to use, reliable, standardized
- **Tool Categories (Task Groups)**: Organized tool stations - woodworking, metalworking, electrical, plumbing
- **Custom Jigs (Custom Tasks)**: Specialized fixtures you build for specific, repeated operations unique to your projects
- **Tool Manual (Task Documentation)**: Detailed instructions for each tool's proper use, safety, and capabilities
- **Workshop Assistant (Azure DevOps Agent)**: The skilled helper who operates all tools according to your project plans
- **Quality Control (Task Validation)**: Ensuring each tool produces the expected results before moving to the next step

Just as a workshop provides both standard tools and the ability to create custom fixtures, Azure DevOps offers built-in tasks for common operations and the flexibility to develop specialized tasks for unique requirements.

## Built-in Task Categories

### 1. Build Tasks

```yaml
# .NET Core CLI Task
- task: DotNetCoreCLI@2
  displayName: 'Build .NET Application'
  inputs:
    command: 'build'
    projects: '**/*.csproj'
    arguments: '--configuration Release --no-restore'

# Node.js Task
- task: NodeTool@0
  displayName: 'Install Node.js'
  inputs:
    versionSpec: '18.x'

- task: Npm@1
  displayName: 'Install npm packages'
  inputs:
    command: 'install'
    workingDir: 'src/web'

# Maven Task
- task: Maven@3
  displayName: 'Build with Maven'
  inputs:
    mavenPomFile: 'pom.xml'
    goals: 'clean compile'
    options: '-Dmaven.test.skip=true'

# MSBuild Task
- task: MSBuild@1
  displayName: 'Build Visual Studio solution'
  inputs:
    solution: '**/*.sln'
    configuration: 'Release'
    platform: 'Any CPU'
    msbuildArguments: '/p:OutputPath=$(Build.ArtifactStagingDirectory)'
```

### 2. Test Tasks

```yaml
# Visual Studio Test Task
- task: VSTest@2
  displayName: 'Run unit tests'
  inputs:
    testSelector: 'testAssemblies'
    testAssemblyVer2: |
      **\*Tests.dll
      !**\*TestAdapter.dll
      !**\obj\**
    searchFolder: '$(System.DefaultWorkingDirectory)'
    runInParallel: true
    codeCoverageEnabled: true

# .NET Core Test Task
- task: DotNetCoreCLI@2
  displayName: 'Run .NET Core tests'
  inputs:
    command: 'test'
    projects: '**/*Tests.csproj'
    arguments: '--configuration Release --collect:"XPlat Code Coverage" --logger trx'

# Publish Test Results
- task: PublishTestResults@2
  displayName: 'Publish test results'
  condition: always()
  inputs:
    testResultsFormat: 'VSTest'
    testResultsFiles: '**/*.trx'
    testRunTitle: 'Unit Tests'
    mergeTestResults: true

# Publish Code Coverage
- task: PublishCodeCoverageResults@1
  displayName: 'Publish code coverage'
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'
```

### 3. Deploy Tasks

```yaml
# Azure Web App Deployment
- task: AzureWebApp@1
  displayName: 'Deploy to Azure Web App'
  inputs:
    azureSubscription: 'Azure-Production-Connection'
    appType: 'webApp'
    appName: 'myapp-prod'
    package: '$(Pipeline.Workspace)/drop/**/*.zip'
    deploymentMethod: 'zipDeploy'
    appSettings: |
      -ASPNETCORE_ENVIRONMENT Production
      -ConnectionStrings:DefaultConnection "$(ProductionConnectionString)"

# Kubernetes Deployment
- task: KubernetesManifest@0
  displayName: 'Deploy to Kubernetes'
  inputs:
    action: 'deploy'
    kubernetesServiceConnection: 'k8s-cluster-connection'
    namespace: 'production'
    manifests: |
      k8s/deployment.yaml
      k8s/service.yaml
      k8s/ingress.yaml

# Azure Resource Manager Template
- task: AzureResourceManagerTemplateDeployment@3
  displayName: 'Deploy ARM template'
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: 'Azure-Connection'
    subscriptionId: '$(AzureSubscriptionId)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: 'rg-myapp-prod'
    location: 'East US'
    templateLocation: 'Linked artifact'
    csmFile: '$(Pipeline.Workspace)/infrastructure/main.json'
    csmParametersFile: '$(Pipeline.Workspace)/infrastructure/parameters.json'
```

### 4. Utility Tasks

```yaml
# Copy Files
- task: CopyFiles@2
  displayName: 'Copy configuration files'
  inputs:
    sourceFolder: 'config'
    contents: '**/*.json'
    targetFolder: '$(Build.ArtifactStagingDirectory)/config'
    cleanTargetFolder: true

# Download Build Artifacts
- task: DownloadBuildArtifacts@0
  displayName: 'Download build artifacts'
  inputs:
    buildType: 'current'
    downloadType: 'single'
    artifactName: 'drop'
    downloadPath: '$(Pipeline.Workspace)'

# Archive Files
- task: ArchiveFiles@2
  displayName: 'Archive application files'
  inputs:
    rootFolderOrFile: '$(Build.ArtifactStagingDirectory)'
    includeRootFolder: false
    archiveType: 'zip'
    archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'

# Extract Files
- task: ExtractFiles@1
  displayName: 'Extract downloaded package'
  inputs:
    archiveFilePatterns: '$(Pipeline.Workspace)/package.zip'
    destinationFolder: '$(Pipeline.Workspace)/extracted'
    cleanDestinationFolder: true
```

## Comprehensive Example: Multi-Technology Build Pipeline

```yaml
name: 'Full-Stack-Build-$(Date:yyyyMMdd)$(Rev:.r)'

trigger:
  branches:
    include:
    - main
    - develop
  paths:
    include:
    - src/
    exclude:
    - docs/

variables:
  buildConfiguration: 'Release'
  nodeVersion: '18.x'
  dotnetVersion: '6.0.x'
  pythonVersion: '3.9'

stages:
- stage: BuildBackend
  displayName: 'Build Backend Services'
  jobs:
  - job: BuildDotNetAPI
    displayName: 'Build .NET API'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Setup .NET environment
    - task: UseDotNet@2
      displayName: 'Install .NET SDK $(dotnetVersion)'
      inputs:
        version: '$(dotnetVersion)'
        includePreviewVersions: false

    # Cache NuGet packages
    - task: Cache@2
      displayName: 'Cache NuGet packages'
      inputs:
        key: 'nuget | "$(Agent.OS)" | **/packages.lock.json'
        restoreKeys: |
          nuget | "$(Agent.OS)"
          nuget
        path: '$(NUGET_PACKAGES)'

    # Restore dependencies
    - task: DotNetCoreCLI@2
      displayName: 'Restore NuGet packages'
      inputs:
        command: 'restore'
        projects: 'src/api/**/*.csproj'
        feedsToUse: 'select'
        verbosityRestore: 'Minimal'

    # Build application
    - task: DotNetCoreCLI@2
      displayName: 'Build API project'
      inputs:
        command: 'build'
        projects: 'src/api/**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    # Run unit tests
    - task: DotNetCoreCLI@2
      displayName: 'Run API unit tests'
      inputs:
        command: 'test'
        projects: 'src/api/**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage" --logger trx --results-directory $(Common.TestResultsDirectory)'

    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish test results'
      condition: always()
      inputs:
        testRunner: 'VSTest'
        testResultsFiles: '$(Common.TestResultsDirectory)/**/*.trx'
        testRunTitle: '.NET API Tests'
        mergeTestResults: true

    # Publish code coverage
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish code coverage'
      condition: succeededOrFailed()
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Common.TestResultsDirectory)/**/coverage.cobertura.xml'

    # Static code analysis
    - task: SonarCloudPrepare@1
      displayName: 'Prepare SonarCloud analysis'
      inputs:
        SonarCloud: 'SonarCloud-Connection'
        organization: 'my-org'
        scannerMode: 'MSBuild'
        projectKey: 'myproject-api'
        projectName: 'My Project API'

    - task: SonarCloudAnalyze@1
      displayName: 'Run SonarCloud analysis'

    - task: SonarCloudPublish@1
      displayName: 'Publish SonarCloud quality gate'
      inputs:
        pollingTimeoutSec: '300'

    # Create deployment package
    - task: DotNetCoreCLI@2
      displayName: 'Publish API for deployment'
      inputs:
        command: 'publish'
        publishWebProjects: false
        projects: 'src/api/MyProject.API/MyProject.API.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --output $(Build.ArtifactStagingDirectory)/api'

    # Archive API artifacts
    - task: ArchiveFiles@2
      displayName: 'Archive API deployment package'
      inputs:
        rootFolderOrFile: '$(Build.ArtifactStagingDirectory)/api'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/api-package.zip'

    # Publish build artifacts
    - task: PublishBuildArtifacts@1
      displayName: 'Publish API artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/api-package.zip'
        artifactName: 'api-drop'

  - job: BuildPythonServices
    displayName: 'Build Python Microservices'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Setup Python environment
    - task: UsePythonVersion@0
      displayName: 'Use Python $(pythonVersion)'
      inputs:
        versionSpec: '$(pythonVersion)'
        addToPath: true

    # Cache pip packages
    - task: Cache@2
      displayName: 'Cache pip packages'
      inputs:
        key: 'python | "$(Agent.OS)" | src/services/requirements.txt'
        restoreKeys: |
          python | "$(Agent.OS)"
          python
        path: '$(Pipeline.Workspace)/.pip'

    # Install dependencies
    - script: |
        python -m pip install --upgrade pip
        pip install --cache-dir $(Pipeline.Workspace)/.pip -r src/services/requirements.txt
        pip install --cache-dir $(Pipeline.Workspace)/.pip pytest pytest-cov flake8 mypy
      displayName: 'Install Python dependencies'

    # Code quality checks
    - script: |
        flake8 src/services --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 src/services --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
      displayName: 'Run Flake8 linting'

    # Type checking
    - script: |
        mypy src/services --ignore-missing-imports
      displayName: 'Run MyPy type checking'
      continueOnError: true

    # Run tests with coverage
    - script: |
        pytest src/services/tests --junitxml=junit/test-results.xml --cov=src/services --cov-report=xml --cov-report=html
      displayName: 'Run Python tests'

    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish Python test results'
      condition: always()
      inputs:
        testResultsFiles: 'junit/test-results.xml'
        testRunTitle: 'Python Microservices Tests'

    # Publish code coverage
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish Python code coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: 'coverage.xml'
        reportDirectory: 'htmlcov'

    # Package Python services
    - script: |
        mkdir -p $(Build.ArtifactStagingDirectory)/python-services
        cp -r src/services/* $(Build.ArtifactStagingDirectory)/python-services/
        cp requirements.txt $(Build.ArtifactStagingDirectory)/python-services/
      displayName: 'Package Python services'

    # Create deployment package
    - task: ArchiveFiles@2
      displayName: 'Archive Python services'
      inputs:
        rootFolderOrFile: '$(Build.ArtifactStagingDirectory)/python-services'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/python-services.zip'

    # Publish artifacts
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Python artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/python-services.zip'
        artifactName: 'python-drop'

- stage: BuildFrontend
  displayName: 'Build Frontend Applications'
  jobs:
  - job: BuildReactApp
    displayName: 'Build React Application'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Setup Node.js environment
    - task: NodeTool@0
      displayName: 'Install Node.js $(nodeVersion)'
      inputs:
        versionSpec: '$(nodeVersion)'

    # Cache node modules
    - task: Cache@2
      displayName: 'Cache npm packages'
      inputs:
        key: 'npm | "$(Agent.OS)" | src/web/package-lock.json'
        restoreKeys: |
          npm | "$(Agent.OS)"
        path: '$(npm_config_cache)'

    # Install dependencies
    - task: Npm@1
      displayName: 'Install npm dependencies'
      inputs:
        command: 'ci'
        workingDir: 'src/web'

    # Run linting
    - task: Npm@1
      displayName: 'Run ESLint'
      inputs:
        command: 'custom'
        workingDir: 'src/web'
        customCommand: 'run lint'

    # Run type checking
    - task: Npm@1
      displayName: 'Run TypeScript check'
      inputs:
        command: 'custom'
        workingDir: 'src/web'
        customCommand: 'run type-check'

    # Run unit tests
    - task: Npm@1
      displayName: 'Run Jest tests'
      inputs:
        command: 'custom'
        workingDir: 'src/web'
        customCommand: 'run test:ci'

    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish Jest test results'
      condition: always()
      inputs:
        testResultsFiles: 'src/web/test-results.xml'
        testRunTitle: 'React Unit Tests'

    # Publish code coverage
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish Jest code coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: 'src/web/coverage/cobertura-coverage.xml'
        reportDirectory: 'src/web/coverage/lcov-report'

    # Build production bundle
    - task: Npm@1
      displayName: 'Build React app'
      inputs:
        command: 'custom'
        workingDir: 'src/web'
        customCommand: 'run build'

    # Bundle analysis
    - task: Npm@1
      displayName: 'Analyze bundle size'
      inputs:
        command: 'custom'
        workingDir: 'src/web'
        customCommand: 'run bundle-analyzer'
      continueOnError: true

    # Copy build output
    - task: CopyFiles@2
      displayName: 'Copy React build files'
      inputs:
        sourceFolder: 'src/web/build'
        contents: '**'
        targetFolder: '$(Build.ArtifactStagingDirectory)/web'
        cleanTargetFolder: true

    # Create deployment package
    - task: ArchiveFiles@2
      displayName: 'Archive React app'
      inputs:
        rootFolderOrFile: '$(Build.ArtifactStagingDirectory)/web'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/web-app.zip'

    # Publish artifacts
    - task: PublishBuildArtifacts@1
      displayName: 'Publish web artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/web-app.zip'
        artifactName: 'web-drop'

- stage: BuildInfrastructure
  displayName: 'Build Infrastructure Templates'
  jobs:
  - job: ValidateTemplates
    displayName: 'Validate ARM Templates'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # Azure CLI setup
    - task: AzureCLI@2
      displayName: 'Validate ARM templates'
      inputs:
        azureSubscription: 'Azure-Validation-Connection'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          echo "Validating ARM templates..."
          
          # Validate main template
          az deployment group validate \
            --resource-group rg-validation \
            --template-file infrastructure/main.json \
            --parameters infrastructure/parameters-dev.json
          
          # Validate nested templates
          for template in infrastructure/modules/*.json; do
            echo "Validating $template"
            az deployment group validate \
              --resource-group rg-validation \
              --template-file "$template" \
              --parameters "{}"
          done

    # ARM Template Toolkit (arm-ttk) validation
    - task: PowerShell@2
      displayName: 'Run ARM TTK validation'
      inputs:
        targetType: 'inline'
        script: |
          # Install ARM TTK
          Install-Module -Name arm-ttk -Force -Scope CurrentUser
          
          # Run tests
          $results = Test-AzTemplate -TemplatePath "infrastructure/"
          
          # Output results
          $results | ForEach-Object {
            if ($_.Errors.Count -gt 0) {
              Write-Error "Template validation failed: $($_.File)"
              $_.Errors | ForEach-Object { Write-Error $_.Message }
            } else {
              Write-Host "✓ Template validation passed: $($_.File)"
            }
          }

    # Package infrastructure templates
    - task: CopyFiles@2
      displayName: 'Copy infrastructure files'
      inputs:
        sourceFolder: 'infrastructure'
        contents: '**'
        targetFolder: '$(Build.ArtifactStagingDirectory)/infrastructure'
        cleanTargetFolder: true

    - task: PublishBuildArtifacts@1
      displayName: 'Publish infrastructure artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/infrastructure'
        artifactName: 'infrastructure-drop'

- stage: IntegrationTests
  displayName: 'Integration and E2E Testing'
  dependsOn: 
  - BuildBackend
  - BuildFrontend
  condition: succeeded()
  jobs:
  - job: RunIntegrationTests
    displayName: 'Integration Testing'
    pool:
      vmImage: 'ubuntu-latest'
    services:
      redis: redis:latest
      postgres: 
        image: postgres:13
        env:
          POSTGRES_PASSWORD: testpassword
          POSTGRES_DB: testdb
    steps:
    # Download all artifacts
    - task: DownloadBuildArtifacts@0
      displayName: 'Download API artifacts'
      inputs:
        buildType: 'current'
        downloadType: 'single'
        artifactName: 'api-drop'
        downloadPath: '$(Pipeline.Workspace)'

    - task: DownloadBuildArtifacts@0
      displayName: 'Download web artifacts'
      inputs:
        buildType: 'current'
        downloadType: 'single'
        artifactName: 'web-drop'
        downloadPath: '$(Pipeline.Workspace)'

    # Extract artifacts
    - task: ExtractFiles@1
      displayName: 'Extract API package'
      inputs:
        archiveFilePatterns: '$(Pipeline.Workspace)/api-drop/api-package.zip'
        destinationFolder: '$(Pipeline.Workspace)/api'
        cleanDestinationFolder: true

    - task: ExtractFiles@1
      displayName: 'Extract web package'
      inputs:
        archiveFilePatterns: '$(Pipeline.Workspace)/web-drop/web-app.zip'
        destinationFolder: '$(Pipeline.Workspace)/web'
        cleanDestinationFolder: true

    # Setup test environment
    - task: UseDotNet@2
      inputs:
        version: '$(dotnetVersion)'

    - task: NodeTool@0
      inputs:
        versionSpec: '$(nodeVersion)'

    # Start API in background
    - script: |
        cd $(Pipeline.Workspace)/api
        nohup dotnet MyProject.API.dll &
        sleep 10
        curl -f http://localhost:5000/health || exit 1
      displayName: 'Start API service'

    # Serve web app
    - script: |
        cd $(Pipeline.Workspace)/web
        npx serve -l 3000 . &
        sleep 5
        curl -f http://localhost:3000 || exit 1
      displayName: 'Start web application'

    # Run integration tests
    - task: DotNetCoreCLI@2
      displayName: 'Run integration tests'
      inputs:
        command: 'test'
        projects: 'tests/integration/**/*.csproj'
        arguments: '--configuration Release --logger trx --results-directory $(Common.TestResultsDirectory)'
      env:
        API_BASE_URL: 'http://localhost:5000'
        WEB_BASE_URL: 'http://localhost:3000'

    # Run E2E tests with Playwright
    - task: Npm@1
      displayName: 'Install Playwright'
      inputs:
        command: 'custom'
        workingDir: 'tests/e2e'
        customCommand: 'ci'

    - script: |
        cd tests/e2e
        npx playwright install chromium
        npx playwright test --reporter=junit
      displayName: 'Run E2E tests'
      env:
        BASE_URL: 'http://localhost:3000'

    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish integration test results'
      condition: always()
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '$(Common.TestResultsDirectory)/**/*.trx'
        testRunTitle: 'Integration Tests'

    - task: PublishTestResults@2
      displayName: 'Publish E2E test results'
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'tests/e2e/test-results/results.xml'
        testRunTitle: 'E2E Tests'

    # Publish test artifacts
    - task: PublishBuildArtifacts@1
      displayName: 'Publish test screenshots'
      condition: failed()
      inputs:
        pathToPublish: 'tests/e2e/test-results'
        artifactName: 'test-screenshots'

- stage: SecurityScanning
  displayName: 'Security and Compliance Scanning'
  dependsOn: IntegrationTests
  condition: succeeded()
  jobs:
  - job: SecurityScan
    displayName: 'Security Scanning'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    # OWASP Dependency Check
    - task: dependency-check-build-task@6
      displayName: 'OWASP Dependency Check'
      inputs:
        projectName: 'MyProject'
        scanPath: '.'
        format: 'ALL'
        additionalArguments: '--enableRetired --enableExperimental'

    # Publish security results
    - task: PublishTestResults@2
      displayName: 'Publish dependency check results'
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'dependency-check-junit.xml'
        testRunTitle: 'OWASP Dependency Check'

    # Container security scanning (if using containers)
    - task: AzureCLI@2
      displayName: 'Container security scan'
      condition: and(succeeded(), eq(variables.useContainers, 'true'))
      inputs:
        azureSubscription: 'Azure-Security-Connection'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          # Scan container images for vulnerabilities
          az acr check-health --registry myregistry
          
          # Example: Trivy scanning
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image myregistry.azurecr.io/myapp:latest

    # License compliance check
    - task: PowerShell@2
      displayName: 'License compliance check'
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Checking license compliance..."
          
          # Check .NET packages
          dotnet list package --include-transitive --format json | 
            ConvertFrom-Json | 
            ForEach-Object { 
              $_.projects.frameworks.dependencies | 
              Where-Object { $_.type -eq "Direct" } 
            }
          
          # Check npm packages (if applicable)
          if (Test-Path "src/web/package.json") {
            cd src/web
            npm ls --json | ConvertFrom-Json | Select-Object dependencies
          }
```

## Custom Task Development

### 1. Creating a PowerShell Custom Task

```yaml
# File: custom-tasks/backup-database/task.json
{
  "$schema": "https://raw.githubusercontent.com/Microsoft/azure-pipelines-task-lib/master/tasks.schema.json",
  "id": "12345678-1234-1234-1234-123456789012",
  "name": "BackupDatabase",
  "friendlyName": "Database Backup Task",
  "description": "Creates a backup of the specified database",
  "author": "Your Team",
  "category": "Deploy",
  "version": {
    "Major": 1,
    "Minor": 0,
    "Patch": 0
  },
  "instanceNameFormat": "Backup $(databaseName) database",
  "inputs": [
    {
      "name": "connectionString",
      "type": "string",
      "label": "Connection String",
      "defaultValue": "",
      "required": true,
      "helpMarkDown": "Database connection string"
    },
    {
      "name": "databaseName",
      "type": "string",
      "label": "Database Name",
      "defaultValue": "",
      "required": true,
      "helpMarkDown": "Name of the database to backup"
    },
    {
      "name": "backupLocation",
      "type": "string",
      "label": "Backup Location",
      "defaultValue": "",
      "required": true,
      "helpMarkDown": "Path where backup file will be stored"
    },
    {
      "name": "compressionLevel",
      "type": "pickList",
      "label": "Compression Level",
      "defaultValue": "medium",
      "required": false,
      "options": {
        "none": "No Compression",
        "low": "Low Compression",
        "medium": "Medium Compression",
        "high": "High Compression"
      },
      "helpMarkDown": "Level of compression to apply to the backup"
    }
  ],
  "execution": {
    "PowerShell3": {
      "target": "backup-database.ps1"
    }
  }
}
```

```powershell
# File: custom-tasks/backup-database/backup-database.ps1
[CmdletBinding()]
param()

# Import Azure DevOps PowerShell module
Import-Module "$PSScriptRoot/node_modules/azure-pipelines-task-lib/PowerShell/VstsTaskSdk"

try {
    # Get input parameters
    $connectionString = Get-VstsInput -Name "connectionString" -Require
    $databaseName = Get-VstsInput -Name "databaseName" -Require
    $backupLocation = Get-VstsInput -Name "backupLocation" -Require
    $compressionLevel = Get-VstsInput -Name "compressionLevel"
    
    Write-Host "Starting database backup process..."
    Write-Host "Database: $databaseName"
    Write-Host "Backup Location: $backupLocation"
    Write-Host "Compression Level: $compressionLevel"
    
    # Generate backup filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFileName = "$databaseName`_$timestamp.bak"
    $fullBackupPath = Join-Path $backupLocation $backupFileName
    
    # Create backup directory if it doesn't exist
    $backupDir = Split-Path $fullBackupPath -Parent
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-Host "Created backup directory: $backupDir"
    }
    
    # Build SQL backup command
    $compressionOption = switch ($compressionLevel) {
        "low" { "COMPRESSION" }
        "medium" { "COMPRESSION" }
        "high" { "COMPRESSION" }
        default { "" }
    }
    
    $backupQuery = @"
BACKUP DATABASE [$databaseName] 
TO DISK = '$fullBackupPath'
WITH FORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10
$(if ($compressionOption) { ", $compressionOption" })
"@
    
    Write-Host "Executing backup command..."
    Write-Host $backupQuery
    
    # Execute backup using SqlServer module or sqlcmd
    try {
        # Using SqlServer PowerShell module
        Invoke-Sqlcmd -ConnectionString $connectionString -Query $backupQuery -QueryTimeout 3600
        
        # Verify backup file was created
        if (Test-Path $fullBackupPath) {
            $backupSize = (Get-Item $fullBackupPath).Length / 1MB
            Write-Host "✅ Backup completed successfully!"
            Write-Host "Backup file: $fullBackupPath"
            Write-Host "Backup size: $([math]::Round($backupSize, 2)) MB"
            
            # Set output variable for use in subsequent tasks
            Write-Host "##vso[task.setvariable variable=backupFilePath;isOutput=true]$fullBackupPath"
            Write-Host "##vso[task.setvariable variable=backupFileName;isOutput=true]$backupFileName"
        } else {
            throw "Backup file was not created at expected location: $fullBackupPath"
        }
        
    } catch {
        Write-Error "Failed to create database backup: $($_.Exception.Message)"
        Write-Host "##vso[task.logissue type=error]Database backup failed: $($_.Exception.Message)"
        exit 1
    }
    
} catch {
    Write-Error "Task failed: $($_.Exception.Message)"
    Write-Host "##vso[task.logissue type=error]Custom backup task failed: $($_.Exception.Message)"
    exit 1
} finally {
    Write-Host "Database backup task completed."
}
```

### 2. Using Custom Task in Pipeline

```yaml
# Install custom task extension first, then use in pipeline
steps:
- task: BackupDatabase@1
  displayName: 'Backup production database'
  inputs:
    connectionString: '$(ProductionConnectionString)'
    databaseName: 'MyAppDatabase'
    backupLocation: '$(Agent.TempDirectory)/backups'
    compressionLevel: 'high'
  name: 'DatabaseBackup'

- script: |
    echo "Backup created at: $(DatabaseBackup.backupFilePath)"
    echo "Backup file name: $(DatabaseBackup.backupFileName)"
  displayName: 'Display backup information'
```

### 3. Node.js Custom Task Example

```typescript
// File: custom-tasks/deploy-to-cdn/deploy-to-cdn.ts
import * as tl from 'azure-pipelines-task-lib/task';
import * as path from 'path';
import { BlobServiceClient } from '@azure/storage-blob';

async function run() {
    try {
        // Get inputs
        const sourceFolder = tl.getPathInput('sourceFolder', true)!;
        const storageConnectionString = tl.getInput('storageConnectionString', true)!;
        const containerName = tl.getInput('containerName', true)!;
        const prefix = tl.getInput('prefix', false) || '';
        const cacheControl = tl.getInput('cacheControl', false) || 'public, max-age=31536000';
        
        console.log(`Deploying files from ${sourceFolder} to CDN container ${containerName}`);
        
        // Initialize Azure Storage client
        const blobServiceClient = BlobServiceClient.fromConnectionString(storageConnectionString);
        const containerClient = blobServiceClient.getContainerClient(containerName);
        
        // Ensure container exists
        await containerClient.createIfNotExists({
            access: 'blob'
        });
        
        // Get list of files to upload
        const files = tl.find(sourceFolder);
        let uploadCount = 0;
        
        for (const file of files) {
            if (tl.stats(file).isFile()) {
                const relativePath = path.relative(sourceFolder, file);
                const blobName = prefix ? `${prefix}/${relativePath}` : relativePath;
                
                console.log(`Uploading ${relativePath} to ${blobName}`);
                
                const blockBlobClient = containerClient.getBlockBlobClient(blobName);
                
                // Determine content type
                const contentType = getContentType(file);
                
                // Upload file
                await blockBlobClient.uploadFile(file, {
                    blobHTTPHeaders: {
                        blobContentType: contentType,
                        blobCacheControl: cacheControl
                    }
                });
                
                uploadCount++;
            }
        }
        
        console.log(`✅ Successfully uploaded ${uploadCount} files to CDN`);
        
        // Set output variables
        tl.setVariable('uploadedFileCount', uploadCount.toString());
        tl.setVariable('cdnBaseUrl', `https://${containerClient.accountName}.blob.core.windows.net/${containerName}`);
        
    } catch (err) {
        tl.setResult(tl.TaskResult.Failed, err instanceof Error ? err.message : 'Unknown error');
    }
}

function getContentType(filePath: string): string {
    const ext = path.extname(filePath).toLowerCase();
    const contentTypes: { [key: string]: string } = {
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.woff': 'font/woff',
        '.woff2': 'font/woff2',
        '.ttf': 'font/ttf',
        '.eot': 'application/vnd.ms-fontobject'
    };
    
    return contentTypes[ext] || 'application/octet-stream';
}

run();
```

## Task Best Practices

### 1. Error Handling and Logging

```yaml
- task: PowerShell@2
  displayName: 'Task with proper error handling'
  inputs:
    targetType: 'inline'
    script: |
      try {
        # Your task logic here
        Write-Host "Starting operation..."
        
        # Simulate work
        $result = Invoke-SomeOperation
        
        if ($result.Success) {
          Write-Host "##vso[task.complete result=Succeeded;]Operation completed successfully"
        } else {
          Write-Warning "Operation completed with warnings"
          Write-Host "##vso[task.logissue type=warning]$($result.Message)"
        }
        
      } catch {
        Write-Error "Operation failed: $($_.Exception.Message)"
        Write-Host "##vso[task.logissue type=error]$($_.Exception.Message)"
        Write-Host "##vso[task.complete result=Failed;]"
        exit 1
      }
```

### 2. Task Output Variables

```yaml
- task: PowerShell@2
  displayName: 'Set output variables'
  name: 'MyTask'
  inputs:
    targetType: 'inline'
    script: |
      $version = "1.2.3"
      $buildNumber = "$(Build.BuildId)"
      $deploymentUrl = "https://myapp-$env.azurewebsites.net"
      
      # Set output variables
      Write-Host "##vso[task.setvariable variable=version;isOutput=true]$version"
      Write-Host "##vso[task.setvariable variable=buildNumber;isOutput=true]$buildNumber"
      Write-Host "##vso[task.setvariable variable=deploymentUrl;isOutput=true]$deploymentUrl"

- script: |
    echo "Version: $(MyTask.version)"
    echo "Build: $(MyTask.buildNumber)"
    echo "URL: $(MyTask.deploymentUrl)"
  displayName: 'Use output variables'
```

### 3. Conditional Task Execution

```yaml
# Run task only on specific conditions
- task: AzureWebApp@1
  displayName: 'Deploy to production'
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  inputs:
    azureSubscription: 'Production-Connection'
    appName: 'myapp-prod'

# Run task even if previous tasks failed
- task: PublishTestResults@2
  displayName: 'Publish test results'
  condition: always()
  inputs:
    testResultsFiles: '**/*.trx'

# Run task only if specific variable is set
- task: PowerShell@2
  displayName: 'Optional deployment step'
  condition: and(succeeded(), eq(variables.enableOptionalStep, 'true'))
  inputs:
    targetType: 'inline'
    script: 'Write-Host "Running optional step"'
```

### 4. Task Retry and Timeout

```yaml
# Task with retry logic
- task: PowerShell@2
  displayName: 'Task with retry'
  retryCountOnTaskFailure: 3
  timeoutInMinutes: 15
  inputs:
    targetType: 'inline'
    script: |
      # Your potentially flaky operation
      Write-Host "Attempting operation (attempt $(System.JobAttempt) of 3)"
      
      # Simulate operation that might fail
      if ((Get-Random) % 3 -eq 0) {
        throw "Random failure for demonstration"
      }
      
      Write-Host "Operation succeeded!"
```

## Task Security Considerations

### 1. Secure Variable Handling

```yaml
- task: PowerShell@2
  displayName: 'Handle secure variables'
  inputs:
    targetType: 'inline'
    script: |
      # Never log secure variables directly
      $secureConnection = "$(SecureConnectionString)"
      
      # Use secure variables safely
      if ([string]::IsNullOrEmpty($secureConnection)) {
        Write-Error "Secure connection string is not provided"
        exit 1
      }
      
      Write-Host "Secure connection configured successfully"
      # Don't log the actual value
```

### 2. Input Validation

```yaml
- task: PowerShell@2
  displayName: 'Validate inputs'
  inputs:
    targetType: 'inline'
    script: |
      $environment = "$(Environment)"
      $validEnvironments = @("development", "staging", "production")
      
      if ($environment -notin $validEnvironments) {
        Write-Error "Invalid environment: $environment. Valid values: $($validEnvironments -join ', ')"
        exit 1
      }
      
      Write-Host "Environment validation passed: $environment"
```

Tasks are the building blocks that make Azure DevOps pipelines powerful and flexible. Understanding both built-in tasks and custom task development enables you to create sophisticated CI/CD workflows tailored to your specific needs.
