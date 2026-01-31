# Azure DevOps Pipeline Steps

## Overview
Steps are the individual building blocks of Azure DevOps pipeline jobs. They represent specific actions or tasks that are executed sequentially within a job. Understanding steps is essential for creating detailed, maintainable, and effective pipeline workflows.

## Explanation
A step is the smallest unit of work in an Azure DevOps pipeline. Steps run sequentially within a job and can include various types of actions such as running scripts, executing tasks, checking out code, or publishing artifacts. Each step has its own execution context and can have specific conditions, timeouts, and error handling.

### Key Concepts:
- **Sequential Execution**: Steps run one after another within a job
- **Execution Context**: Each step runs in the context of the job's agent
- **Task Types**: Different types of steps for different purposes
- **Conditional Logic**: Steps can have conditions that determine execution
- **Error Handling**: Steps can continue on error or fail the entire job
- **Timeout Control**: Individual steps can have timeout configurations

## Types of Steps

### 1. Script Steps
- **script**: Run inline scripts (bash on Linux/macOS, cmd on Windows)
- **bash**: Explicitly run bash scripts
- **powershell**: Run PowerShell scripts
- **pwsh**: Run PowerShell Core scripts

### 2. Task Steps
- **task**: Execute predefined Azure DevOps tasks
- Built-in tasks for common operations
- Custom tasks from marketplace

### 3. Utility Steps
- **checkout**: Check out source code from repositories
- **download**: Download artifacts from current or other pipelines
- **publish**: Publish artifacts for use by other jobs/pipelines
- **template**: Include steps from template files

## Analogy
Think of steps like individual instructions in a cooking recipe:

**Recipe (Job)**: "Make Chocolate Chip Cookies"

**Steps (Individual Instructions)**:
1. **Preparation Step** (checkout): "Gather all ingredients and tools"
2. **Setup Step** (script): "Preheat oven to 375°F"
3. **Processing Steps** (tasks): 
   - "Mix flour, baking soda, and salt"
   - "Cream butter and sugars"
   - "Add eggs and vanilla"
4. **Assembly Step** (script): "Combine wet and dry ingredients"
5. **Quality Check** (task): "Check dough consistency"
6. **Production Step** (script): "Shape cookies and place on baking sheet"
7. **Completion Step** (script): "Bake for 9-11 minutes"
8. **Publishing Step** (publish): "Cool and serve cookies"

Just like cooking steps:
- They must be done in the right order
- Each step depends on the previous ones
- If one step fails (burnt cookies), you might stop or continue with caution
- Some steps can be skipped under certain conditions ("if using pre-made dough, skip mixing steps")
- Each step has a specific purpose and expected outcome

## Step Configuration Properties

### Common Properties:
- **displayName**: Human-readable name for the step
- **condition**: Control when a step runs
- **continueOnError**: Whether to continue if step fails
- **timeoutInMinutes**: Maximum execution time for the step
- **retryCountOnTaskFailure**: Number of retries on failure
- **env**: Environment variables for the step

## Example Workflow YAML

```yaml
# Comprehensive steps configuration examples
name: 'Steps Configuration Demo'

# Trigger
trigger:
  branches:
    include: ['main', 'develop']

# Variables
variables:
  - name: buildConfiguration
    value: 'Release'
  - name: projectName
    value: 'MyApplication'
  - name: testFramework
    value: 'NUnit'

# Pipeline
stages:
  - stage: 'StepsDemo'
    displayName: 'Steps Configuration Examples'
    jobs:
      - job: 'BasicStepsJob'
        displayName: 'Basic Steps Examples'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          # Step 1: Checkout step
          - checkout: self
            displayName: 'Checkout source code'
            clean: true
            fetchDepth: 1
            submodules: false

          # Step 2: Simple script step
          - script: |
              echo "=== Basic Script Step ==="
              echo "Project: $(projectName)"
              echo "Build Configuration: $(buildConfiguration)"
              echo "Agent: $(Agent.Name)"
              echo "Build Number: $(Build.BuildNumber)"
              echo "Source Branch: $(Build.SourceBranch)"
            displayName: 'Display build information'

          # Step 3: Bash step with condition
          - bash: |
              echo "=== Conditional Bash Step ==="
              echo "This step only runs on main branch"
              echo "Current branch: $(Build.SourceBranch)"
              echo "Running production-specific checks..."
            displayName: 'Production branch checks'
            condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

          # Step 4: PowerShell step (cross-platform)
          - pwsh: |
              Write-Host "=== PowerShell Core Step ==="
              Write-Host "PowerShell works on all platforms!"
              Write-Host "Current OS: $(Agent.OS)"
              Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
              
              # Create a simple test file
              $testContent = @"
              Build Information:
              - Project: $(projectName)
              - Configuration: $(buildConfiguration)
              - Date: $(Get-Date)
              - Agent: $(Agent.Name)
              "@
              
              $testContent | Out-File -FilePath "build-info.txt"
              Write-Host "Created build-info.txt"
            displayName: 'Cross-platform PowerShell'

          # Step 5: Script with environment variables
          - script: |
              echo "=== Step with Environment Variables ==="
              echo "Custom environment variable: $CUSTOM_VAR"
              echo "Secret environment variable: $SECRET_VAR"
              echo "Build-specific variable: $BUILD_SPECIFIC"
            displayName: 'Environment variables demo'
            env:
              CUSTOM_VAR: 'This is a custom value'
              SECRET_VAR: $(MySecretVariable)  # Reference to pipeline variable
              BUILD_SPECIFIC: '$(projectName)-$(buildConfiguration)'

          # Step 6: Script with timeout and retry
          - script: |
              echo "=== Step with Timeout and Retry ==="
              echo "Simulating a potentially unreliable operation..."
              
              # Simulate random failure for demo
              if [ $((RANDOM % 3)) -eq 0 ]; then
                  echo "✅ Operation succeeded"
                  exit 0
              else
                  echo "❌ Operation failed (simulated)"
                  exit 1
              fi
            displayName: 'Unreliable operation with retry'
            timeoutInMinutes: 2
            retryCountOnTaskFailure: 3
            continueOnError: true

          # Step 7: Task step - .NET setup
          - task: UseDotNet@2
            displayName: 'Setup .NET SDK'
            inputs:
              packageType: 'sdk'
              version: '6.x'
              installationPath: $(Agent.ToolsDirectory)/dotnet

          # Step 8: Script step with error handling
          - script: |
              echo "=== Error Handling Demo ==="
              
              # Function to check command success
              check_command() {
                  if [ $? -eq 0 ]; then
                      echo "✅ $1 succeeded"
                  else
                      echo "❌ $1 failed"
                      return 1
                  fi
              }
              
              # Test commands
              echo "Testing .NET installation..."
              dotnet --version
              check_command ".NET version check"
              
              echo "Testing Git installation..."
              git --version
              check_command "Git version check"
              
              echo "All checks completed"
            displayName: 'Command validation with error handling'

          # Step 9: Multi-line script with complex logic
          - script: |
              echo "=== Complex Logic Step ==="
              
              # Create project structure
              mkdir -p src/{api,web,tests}
              mkdir -p docs
              mkdir -p scripts
              
              # Generate sample files
              cat > src/api/Program.cs << 'EOF'
              using System;
              
              namespace MyApplication.API
              {
                  class Program
                  {
                      static void Main(string[] args)
                      {
                          Console.WriteLine("Hello from $(projectName) API!");
                          Console.WriteLine($"Configuration: $(buildConfiguration)");
                          Console.WriteLine($"Build: $(Build.BuildNumber)");
                      }
                  }
              }
              EOF
              
              cat > src/api/MyApplication.API.csproj << 'EOF'
              <Project Sdk="Microsoft.NET.Sdk">
                <PropertyGroup>
                  <OutputType>Exe</OutputType>
                  <TargetFramework>net6.0</TargetFramework>
                </PropertyGroup>
              </Project>
              EOF
              
              echo "Project structure created:"
              find . -type f -name "*.cs" -o -name "*.csproj" | head -10
            displayName: 'Create project structure'

          # Step 10: Build step
          - script: |
              echo "=== Build Step ==="
              cd src/api
              
              echo "Restoring NuGet packages..."
              dotnet restore
              
              echo "Building project..."
              dotnet build --configuration $(buildConfiguration) --no-restore
              
              echo "Build completed successfully!"
            displayName: 'Build application'

      - job: 'AdvancedStepsJob'
        displayName: 'Advanced Steps Examples'
        pool:
          vmImage: 'ubuntu-latest'
        dependsOn: 'BasicStepsJob'
        condition: succeeded()
        steps:
          # Step 1: Download artifacts from previous job
          - download: current
            artifact: drop
            displayName: 'Download build artifacts'
            condition: false  # Disabled since we don't actually publish artifacts in basic job

          # Step 2: Conditional steps based on variables
          - script: |
              echo "=== Development Environment Step ==="
              echo "Setting up development environment..."
              echo "Installing development tools..."
              echo "Configuring debug settings..."
            displayName: 'Development setup'
            condition: eq(variables['buildConfiguration'], 'Debug')

          - script: |
              echo "=== Production Environment Step ==="
              echo "Setting up production environment..."
              echo "Optimizing for performance..."
              echo "Configuring production settings..."
            displayName: 'Production setup'
            condition: eq(variables['buildConfiguration'], 'Release')

          # Step 3: Testing steps
          - script: |
              echo "=== Unit Tests ==="
              echo "Test Framework: $(testFramework)"
              echo "Running unit tests..."
              
              # Simulate test execution
              echo "Discovering tests..."
              sleep 1
              echo "Running Core.Tests..."
              sleep 2
              echo "✅ Core.Tests: 25 passed, 0 failed"
              echo "Running API.Tests..."
              sleep 2
              echo "✅ API.Tests: 15 passed, 0 failed"
              echo "Running Integration.Tests..."
              sleep 1
              echo "✅ Integration.Tests: 8 passed, 0 failed"
              
              echo "Total: 48 tests passed, 0 failed"
            displayName: 'Run unit tests'

          # Step 4: Code coverage step
          - script: |
              echo "=== Code Coverage Analysis ==="
              echo "Generating code coverage report..."
              
              # Simulate coverage analysis
              sleep 2
              echo "Coverage Results:"
              echo "  Line Coverage: 87.5%"
              echo "  Branch Coverage: 82.3%"
              echo "  Method Coverage: 91.2%"
              
              # Create coverage report
              mkdir -p $(Build.ArtifactStagingDirectory)/coverage
              cat > $(Build.ArtifactStagingDirectory)/coverage/coverage-summary.txt << EOF
              Code Coverage Summary
              =====================
              Generated: $(date)
              Project: $(projectName)
              Configuration: $(buildConfiguration)
              
              Coverage Metrics:
              - Line Coverage: 87.5%
              - Branch Coverage: 82.3%
              - Method Coverage: 91.2%
              
              Status: ✅ Coverage meets minimum requirements (80%)
              EOF
            displayName: 'Generate code coverage'

          # Step 5: Security scanning step
          - script: |
              echo "=== Security Scanning ==="
              echo "Running security vulnerability scan..."
              
              # Simulate security scan
              sleep 3
              echo "Vulnerability Scan Results:"
              echo "  High: 0"
              echo "  Medium: 2"
              echo "  Low: 5"
              echo "  Info: 12"
              
              # Check for high vulnerabilities
              high_vulns=0
              if [ $high_vulns -gt 0 ]; then
                  echo "❌ High vulnerabilities found! Failing build."
                  exit 1
              else
                  echo "✅ No high vulnerabilities found."
              fi
            displayName: 'Security vulnerability scan'
            continueOnError: false

          # Step 6: Performance testing step
          - script: |
              echo "=== Performance Testing ==="
              echo "Running performance benchmarks..."
              
              # Simulate performance tests
              start_time=$(date +%s%N)
              sleep 2  # Simulate test execution
              end_time=$(date +%s%N)
              
              duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds
              
              echo "Performance Test Results:"
              echo "  Test Duration: ${duration}ms"
              echo "  API Response Time: 125ms"
              echo "  Throughput: 1,250 requests/second"
              echo "  Memory Usage: 256MB"
              echo "  CPU Usage: 45%"
              
              # Performance thresholds
              max_response_time=200
              current_response_time=125
              
              if [ $current_response_time -lt $max_response_time ]; then
                  echo "✅ Performance tests passed"
              else
                  echo "❌ Performance tests failed - response time too high"
                  exit 1
              fi
            displayName: 'Performance benchmarks'

          # Step 7: Artifact publishing step
          - script: |
              echo "=== Prepare Artifacts ==="
              
              # Create artifacts directory structure
              mkdir -p $(Build.ArtifactStagingDirectory)/app
              mkdir -p $(Build.ArtifactStagingDirectory)/tests
              mkdir -p $(Build.ArtifactStagingDirectory)/reports
              
              # Copy application files (simulated)
              echo "Copying application files..."
              cp build-info.txt $(Build.ArtifactStagingDirectory)/app/ 2>/dev/null || echo "No build-info.txt found"
              
              # Create deployment manifest
              cat > $(Build.ArtifactStagingDirectory)/app/deployment-manifest.json << EOF
              {
                "application": "$(projectName)",
                "version": "$(Build.BuildNumber)",
                "configuration": "$(buildConfiguration)",
                "buildDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
                "sourceCommit": "$(Build.SourceVersion)",
                "sourceBranch": "$(Build.SourceBranchName)"
              }
              EOF
              
              echo "Artifacts prepared:"
              find $(Build.ArtifactStagingDirectory) -type f
            displayName: 'Prepare deployment artifacts'

          # Step 8: Publish artifacts
          - publish: $(Build.ArtifactStagingDirectory)/app
            artifact: 'application-$(buildConfiguration)'
            displayName: 'Publish application artifacts'

          - publish: $(Build.ArtifactStagingDirectory)/coverage
            artifact: 'coverage-reports'
            displayName: 'Publish coverage reports'
            condition: succeededOrFailed()  # Publish even if tests failed

      - job: 'PlatformSpecificSteps'
        displayName: 'Platform-Specific Steps'
        strategy:
          matrix:
            Linux:
              imageName: 'ubuntu-latest'
              platform: 'linux'
            Windows:
              imageName: 'windows-latest'
              platform: 'windows'
        pool:
          vmImage: $(imageName)
        steps:
          # Cross-platform step
          - script: |
              echo "=== Cross-Platform Step ==="
              echo "Platform: $(platform)"
              echo "Agent OS: $(Agent.OS)"
            displayName: 'Cross-platform information'

          # Linux-specific steps
          - bash: |
              echo "=== Linux-Specific Steps ==="
              echo "Running Linux-specific commands..."
              
              # System information
              echo "Distribution: $(lsb_release -d | cut -f2)"
              echo "Kernel: $(uname -r)"
              echo "Available packages:"
              apt list --installed 2>/dev/null | grep -E "git|curl|wget" | head -5
              
              # Linux-specific build tools
              echo "Checking build tools..."
              which make && echo "✅ make available" || echo "❌ make not available"
              which gcc && echo "✅ gcc available" || echo "❌ gcc not available"
            displayName: 'Linux-specific operations'
            condition: eq(variables['Agent.OS'], 'Linux')

          # Windows-specific steps
          - powershell: |
              Write-Host "=== Windows-Specific Steps ==="
              Write-Host "Running Windows-specific commands..."
              
              # System information
              $os = Get-WmiObject -Class Win32_OperatingSystem
              Write-Host "OS: $($os.Caption)"
              Write-Host "Version: $($os.Version)"
              
              # Windows-specific tools
              Write-Host "Checking Windows tools..."
              if (Get-Command "msbuild" -ErrorAction SilentlyContinue) {
                  Write-Host "✅ MSBuild available"
              } else {
                  Write-Host "❌ MSBuild not available"
              }
              
              if (Get-Command "dotnet" -ErrorAction SilentlyContinue) {
                  Write-Host "✅ .NET CLI available"
                  dotnet --version
              } else {
                  Write-Host "❌ .NET CLI not available"
              }
            displayName: 'Windows-specific operations'
            condition: eq(variables['Agent.OS'], 'Windows_NT')
```

## Step Conditions

### Basic Conditions
```yaml
steps:
  - script: echo "Always runs"
    condition: always()

  - script: echo "Only on success"
    condition: succeeded()

  - script: echo "Only on failure"
    condition: failed()

  - script: echo "On success or failure"
    condition: succeededOrFailed()
```

### Variable-Based Conditions
```yaml
steps:
  - script: echo "Production deployment"
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

  - script: echo "Debug build"
    condition: eq(variables['buildConfiguration'], 'Debug')
```

### Complex Conditions
```yaml
steps:
  - script: echo "Complex condition"
    condition: |
      and(
        succeeded(),
        eq(variables['Build.Reason'], 'PullRequest'),
        startsWith(variables['Build.SourceBranch'], 'refs/heads/feature/')
      )
```

## Step Templates

### Reusable Step Template
```yaml
# File: steps/build-template.yml
parameters:
  - name: buildConfiguration
    type: string
    default: 'Release'

steps:
  - script: |
      echo "Building with configuration: ${{ parameters.buildConfiguration }}"
      dotnet build --configuration ${{ parameters.buildConfiguration }}
    displayName: 'Build application'
```

### Using Templates
```yaml
steps:
  - template: steps/build-template.yml
    parameters:
      buildConfiguration: $(buildConfiguration)
```

## Best Practices

### 1. Step Organization
- **Clear Names**: Use descriptive display names
- **Logical Grouping**: Group related operations in the same step
- **Single Responsibility**: Each step should have a clear purpose

### 2. Error Handling
- **Appropriate Conditions**: Use conditions to control step execution
- **Continue on Error**: Use `continueOnError` judiciously
- **Retry Logic**: Implement retries for transient failures

### 3. Performance
- **Step Granularity**: Balance between too many small steps and too few large steps
- **Parallel Operations**: Use multiple jobs for parallel execution instead of sequential steps
- **Efficient Scripts**: Optimize script execution time

### 4. Maintainability
- **Template Usage**: Use templates for reusable step sequences
- **Variable References**: Use variables instead of hardcoded values
- **Documentation**: Comment complex step logic

### 5. Security
- **Secret Handling**: Use secure variables for sensitive data
- **Input Validation**: Validate inputs in script steps
- **Minimal Permissions**: Run steps with least required privileges

## Common Step Patterns

### Setup and Teardown
```yaml
steps:
  - script: echo "Setup"
    displayName: 'Environment setup'
  
  - script: echo "Main work"
    displayName: 'Main operations'
  
  - script: echo "Cleanup"
    displayName: 'Environment cleanup'
    condition: always()
```

### Error Recovery
```yaml
steps:
  - script: |
      # Main operation
      echo "Attempting main operation..."
      exit 1  # Simulate failure
    displayName: 'Main operation'
    continueOnError: true
  
  - script: |
      echo "Running fallback operation..."
    displayName: 'Fallback operation'
    condition: failed()
```

### Conditional Deployment
```yaml
steps:
  - script: echo "Deploy to dev"
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/develop')
  
  - script: echo "Deploy to staging"
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/release/*')
  
  - script: echo "Deploy to production"
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
```

Understanding steps and their configuration is crucial for creating detailed, maintainable, and robust Azure DevOps pipelines that handle various scenarios and requirements effectively.
