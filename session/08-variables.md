# Azure DevOps Pipeline Variables

## Overview
Variables in Azure DevOps Pipelines are key-value pairs that store data and make it available throughout your pipeline execution. They provide a powerful way to parameterize your pipelines, manage configuration settings, and share data between different parts of your workflow.

## Explanation
Variables act as containers for data that can be referenced and used across different stages, jobs, and steps in your pipeline. They help eliminate hardcoded values, enable reusability, and provide flexibility in pipeline configuration. Variables can be defined at multiple scopes and can be static or dynamic.

### Key Concepts:
- **Scope**: Variables can be defined at pipeline, stage, job, or step level
- **Types**: String, boolean, number, object, and secure variables
- **Predefined Variables**: System-provided variables with build and environment information
- **Variable Groups**: Shared collections of variables across multiple pipelines
- **Runtime Variables**: Variables set during pipeline execution
- **Secret Variables**: Encrypted variables for sensitive data

## Types of Variables

### 1. Pipeline Variables
Defined at the pipeline level and available throughout the pipeline.

### 2. Stage Variables
Defined at the stage level and available to all jobs in that stage.

### 3. Job Variables
Defined at the job level and available to all steps in that job.

### 4. Predefined Variables
System variables automatically provided by Azure DevOps.

### 5. Variable Groups
Shared variables that can be used across multiple pipelines.

### 6. Secret Variables
Encrypted variables for storing sensitive information.

## Analogy
Think of variables like different types of storage in a restaurant kitchen:

**Global Pantry (Pipeline Variables)**:
- Ingredients available to all chefs and stations
- Like "restaurant-name", "opening-hours", "head-chef-name"
- Everyone in the kitchen can access these

**Station Storage (Stage Variables)**:
- Ingredients specific to a cooking station (prep, grill, dessert)
- Like "grill-temperature", "prep-station-tools"
- Only available to that specific station

**Chef's Personal Kit (Job Variables)**:
- Tools and ingredients specific to one chef
- Like "chef-john-knife-set", "mary-special-seasoning"
- Only that chef can use these

**Recipe Cards (Predefined Variables)**:
- Information the restaurant provides automatically
- Like "today-date", "current-season", "kitchen-temperature"
- Always available, you don't need to create them

**Shared Recipe Book (Variable Groups)**:
- Common recipes used across multiple restaurants in the chain
- Like "corporate-sauce-recipe", "standard-portion-sizes"
- Shared between different kitchen locations

**Safe (Secret Variables)**:
- Locked storage for valuable items
- Like "safe-combination", "supplier-payment-info"
- Only authorized personnel can access

## Variable Scopes and Precedence

Variables follow a hierarchy where more specific scopes override broader ones:
1. **Step level** (highest precedence)
2. **Job level**
3. **Stage level**
4. **Pipeline level** (lowest precedence)

## Example Workflow YAML

```yaml
# Comprehensive variables configuration examples
name: 'Variables Configuration Demo'

# Trigger
trigger:
  branches:
    include: ['main', 'develop']

# Pipeline-level variables
variables:
  # Simple string variables
  - name: applicationName
    value: 'MyAwesomeApp'
  - name: buildConfiguration
    value: 'Release'
  - name: vmImageName
    value: 'ubuntu-latest'
  
  # Conditional variables
  - name: environmentName
    ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
      value: 'production'
    ${{ elseif eq(variables['Build.SourceBranch'], 'refs/heads/develop') }}:
      value: 'development'
    ${{ else }}:
      value: 'feature'
  
  # Computed variables
  - name: buildNumber
    value: '$(Build.BuildNumber)'
  - name: artifactName
    value: '$(applicationName)-$(buildConfiguration)-$(Build.BuildNumber)'
  
  # Boolean variable
  - name: runIntegrationTests
    value: true
  
  # Variable groups (reference to shared variables)
  - group: 'SharedConfiguration'
  - group: 'DatabaseSettings'

# Multi-stage pipeline demonstrating variable usage
stages:
  # Stage 1: Build with stage-level variables
  - stage: 'Build'
    displayName: 'Build Application'
    variables:
      # Stage-specific variables
      - name: stageSpecificVar
        value: 'BuildStageValue'
      - name: buildToolsVersion
        value: '6.0'
      - name: outputPath
        value: '$(Build.ArtifactStagingDirectory)/build'
    
    jobs:
      - job: 'BuildJob'
        displayName: 'Build and Package'
        pool:
          vmImage: $(vmImageName)
        
        # Job-level variables
        variables:
          - name: jobSpecificVar
            value: 'BuildJobValue'
          - name: compilerFlags
            value: '-O2 -Wall'
        
        steps:
          # Step demonstrating variable usage
          - script: |
              echo "=== Variable Demonstration ==="
              echo "Pipeline Variables:"
              echo "  Application Name: $(applicationName)"
              echo "  Build Configuration: $(buildConfiguration)"
              echo "  Environment: $(environmentName)"
              echo "  VM Image: $(vmImageName)"
              echo "  Run Integration Tests: $(runIntegrationTests)"
              echo ""
              echo "Stage Variables:"
              echo "  Stage Specific: $(stageSpecificVar)"
              echo "  Build Tools Version: $(buildToolsVersion)"
              echo "  Output Path: $(outputPath)"
              echo ""
              echo "Job Variables:"
              echo "  Job Specific: $(jobSpecificVar)"
              echo "  Compiler Flags: $(compilerFlags)"
              echo ""
              echo "Computed Variables:"
              echo "  Build Number: $(buildNumber)"
              echo "  Artifact Name: $(artifactName)"
            displayName: 'Display variable values'

          # Step with step-level variables
          - script: |
              echo "=== Step-Level Variables ==="
              echo "Step Variable: $STEP_VAR"
              echo "Override Test: $OVERRIDE_VAR"
              echo "Environment Variable: $CUSTOM_ENV_VAR"
            displayName: 'Step with custom variables'
            env:
              STEP_VAR: 'StepSpecificValue'
              OVERRIDE_VAR: 'OverriddenValue'  # This overrides any pipeline variable
              CUSTOM_ENV_VAR: 'CustomEnvironmentValue'

          # Predefined variables demonstration
          - script: |
              echo "=== Predefined Variables ==="
              echo "Build Information:"
              echo "  Build ID: $(Build.BuildId)"
              echo "  Build Number: $(Build.BuildNumber)"
              echo "  Build Reason: $(Build.Reason)"
              echo "  Source Branch: $(Build.SourceBranch)"
              echo "  Source Version: $(Build.SourceVersion)"
              echo ""
              echo "Agent Information:"
              echo "  Agent Name: $(Agent.Name)"
              echo "  Agent OS: $(Agent.OS)"
              echo "  Agent Version: $(Agent.Version)"
              echo "  Working Directory: $(Agent.WorkFolder)"
              echo ""
              echo "Pipeline Information:"
              echo "  Pipeline Name: $(Build.DefinitionName)"
              echo "  Repository Name: $(Build.Repository.Name)"
              echo "  Requested For: $(Build.RequestedFor)"
              echo "  Started By: $(Build.StartedBy)"
            displayName: 'Show predefined variables'

          # Dynamic variable setting
          - script: |
              echo "=== Dynamic Variables ==="
              
              # Set variables for use in subsequent steps
              echo "##vso[task.setvariable variable=dynamicVar]DynamicValue-$(date +%s)"
              echo "##vso[task.setvariable variable=buildTimestamp]$(date -u +%Y-%m-%dT%H:%M:%SZ)"
              
              # Set variable for use in other jobs (output variable)
              echo "##vso[task.setvariable variable=crossJobVar;isOutput=true]CrossJobValue-$(Build.BuildNumber)"
              
              # Conditional variable setting
              if [ "$(buildConfiguration)" = "Release" ]; then
                  echo "##vso[task.setvariable variable=deploymentTarget]production"
              else
                  echo "##vso[task.setvariable variable=deploymentTarget]development"
              fi
              
              echo "Dynamic variables set successfully"
            displayName: 'Set dynamic variables'
            name: 'setVars'  # Name needed for output variables

          # Using dynamic variables
          - script: |
              echo "=== Using Dynamic Variables ==="
              echo "Dynamic Variable: $(dynamicVar)"
              echo "Build Timestamp: $(buildTimestamp)"
              echo "Deployment Target: $(deploymentTarget)"
            displayName: 'Use dynamic variables'

          # Conditional logic based on variables
          - script: |
              echo "=== Conditional Execution ==="
              echo "This step runs only in Release configuration"
              echo "Current configuration: $(buildConfiguration)"
            displayName: 'Release-only step'
            condition: eq(variables['buildConfiguration'], 'Release')

          - script: |
              echo "=== Integration Test Preparation ==="
              echo "Preparing integration test environment..."
              echo "Environment: $(environmentName)"
            displayName: 'Prepare integration tests'
            condition: eq(variables['runIntegrationTests'], 'true')

      # Job demonstrating cross-job variable usage
      - job: 'PackageJob'
        displayName: 'Package Application'
        pool:
          vmImage: $(vmImageName)
        dependsOn: 'BuildJob'
        variables:
          # Reference output variable from previous job
          - name: crossJobVariable
            value: $[ dependencies.BuildJob.outputs['setVars.crossJobVar'] ]
        
        steps:
          - script: |
              echo "=== Cross-Job Variable Usage ==="
              echo "Variable from BuildJob: $(crossJobVariable)"
              echo "Application Name: $(applicationName)"
              echo "Artifact Name: $(artifactName)"
            displayName: 'Use cross-job variables'

          - script: |
              echo "=== Packaging Application ==="
              mkdir -p $(outputPath)
              
              # Create package manifest
              cat > $(outputPath)/package-manifest.json << EOF
              {
                "applicationName": "$(applicationName)",
                "version": "$(buildNumber)",
                "configuration": "$(buildConfiguration)",
                "environment": "$(environmentName)",
                "buildTimestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
                "crossJobVariable": "$(crossJobVariable)",
                "artifactName": "$(artifactName)"
              }
              EOF
              
              echo "Package manifest created"
              cat $(outputPath)/package-manifest.json
            displayName: 'Create package'

          - publish: $(outputPath)
            artifact: $(artifactName)
            displayName: 'Publish package'

  # Stage 2: Test with different variable scope
  - stage: 'Test'
    displayName: 'Testing Stage'
    dependsOn: 'Build'
    variables:
      - name: testEnvironment
        value: 'test-$(environmentName)'
      - name: testDatabaseUrl
        value: 'server=test-db;database=$(applicationName)-test'
      - name: maxRetries
        value: 3
    
    jobs:
      - job: 'UnitTests'
        displayName: 'Unit Tests'
        pool:
          vmImage: $(vmImageName)
        variables:
          - name: testFramework
            value: 'NUnit'
          - name: testCategories
            value: 'Unit,Integration'
        
        steps:
          - script: |
              echo "=== Unit Test Configuration ==="
              echo "Test Environment: $(testEnvironment)"
              echo "Test Framework: $(testFramework)"
              echo "Test Categories: $(testCategories)"
              echo "Max Retries: $(maxRetries)"
              echo "Database URL: $(testDatabaseUrl)"
            displayName: 'Test configuration'

          - script: |
              echo "=== Variable Precedence Demo ==="
              
              # Show how variables override each other
              echo "Application Name (Pipeline): $(applicationName)"
              echo "Build Configuration (Pipeline): $(buildConfiguration)"
              echo "Test Environment (Stage): $(testEnvironment)"
              echo "Test Framework (Job): $(testFramework)"
            displayName: 'Variable precedence'

      - job: 'IntegrationTests'
        displayName: 'Integration Tests'
        pool:
          vmImage: $(vmImageName)
        condition: eq(variables['runIntegrationTests'], 'true')
        variables:
          - name: testTimeout
            value: '600'  # 10 minutes
          - name: parallelTests
            value: '4'
        
        steps:
          - script: |
              echo "=== Integration Test Setup ==="
              echo "Running integration tests: $(runIntegrationTests)"
              echo "Test timeout: $(testTimeout) seconds"
              echo "Parallel test threads: $(parallelTests)"
              echo "Environment: $(testEnvironment)"
            displayName: 'Integration test setup'

  # Stage 3: Deployment with environment-specific variables
  - stage: 'Deploy'
    displayName: 'Deployment'
    dependsOn: 'Test'
    condition: succeeded()
    variables:
      # Environment-specific variables using template expressions
      - name: deploymentSlot
        ${{ if eq(variables['environmentName'], 'production') }}:
          value: 'production'
        ${{ else }}:
          value: 'staging'
      
      - name: instanceCount
        ${{ if eq(variables['environmentName'], 'production') }}:
          value: '3'
        ${{ else }}:
          value: '1'
      
      - name: monitoring
        ${{ if eq(variables['environmentName'], 'production') }}:
          value: 'enabled'
        ${{ else }}:
          value: 'basic'
    
    jobs:
      - deployment: 'DeployApp'
        displayName: 'Deploy Application'
        pool:
          vmImage: $(vmImageName)
        environment: $(environmentName)
        variables:
          - name: deploymentMode
            value: 'blue-green'
          - name: healthCheckUrl
            value: 'https://$(applicationName)-$(environmentName).azurewebsites.net/health'
        
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: $(artifactName)
                  displayName: 'Download application package'

                - script: |
                    echo "=== Deployment Configuration ==="
                    echo "Application: $(applicationName)"
                    echo "Environment: $(environmentName)"
                    echo "Deployment Slot: $(deploymentSlot)"
                    echo "Instance Count: $(instanceCount)"
                    echo "Monitoring: $(monitoring)"
                    echo "Deployment Mode: $(deploymentMode)"
                    echo "Health Check URL: $(healthCheckUrl)"
                    echo "Package: $(artifactName)"
                  displayName: 'Deployment configuration'

                - script: |
                    echo "=== Variable Summary ==="
                    echo "All variables used in this deployment:"
                    echo "From Pipeline:"
                    echo "  - applicationName: $(applicationName)"
                    echo "  - buildConfiguration: $(buildConfiguration)"
                    echo "  - environmentName: $(environmentName)"
                    echo "From Stage:"
                    echo "  - deploymentSlot: $(deploymentSlot)"
                    echo "  - instanceCount: $(instanceCount)"
                    echo "  - monitoring: $(monitoring)"
                    echo "From Job:"
                    echo "  - deploymentMode: $(deploymentMode)"
                    echo "  - healthCheckUrl: $(healthCheckUrl)"
                  displayName: 'Variable summary'

                - script: |
                    echo "=== Simulated Deployment ==="
                    echo "Deploying $(applicationName) to $(environmentName)..."
                    echo "Using $(instanceCount) instances"
                    echo "Deployment mode: $(deploymentMode)"
                    
                    # Simulate deployment steps
                    echo "Step 1: Preparing deployment package..."
                    sleep 1
                    echo "Step 2: Updating $(deploymentSlot) slot..."
                    sleep 2
                    echo "Step 3: Health check at $(healthCheckUrl)..."
                    sleep 1
                    echo "Step 4: Enabling monitoring ($(monitoring))..."
                    sleep 1
                    
                    echo "✅ Deployment completed successfully!"
                  displayName: 'Deploy application'

  # Stage 4: Variable validation and troubleshooting
  - stage: 'VariableValidation'
    displayName: 'Variable Validation'
    dependsOn: []  # Run independently
    jobs:
      - job: 'ValidateVariables'
        displayName: 'Validate Variable Configuration'
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              echo "=== Variable Validation ==="
              
              # Function to validate variable
              validate_var() {
                  local var_name="$1"
                  local var_value="$2"
                  
                  if [ -n "$var_value" ]; then
                      echo "✅ $var_name: '$var_value'"
                  else
                      echo "❌ $var_name: NOT SET or EMPTY"
                  fi
              }
              
              echo "Validating required variables:"
              validate_var "applicationName" "$(applicationName)"
              validate_var "buildConfiguration" "$(buildConfiguration)"
              validate_var "environmentName" "$(environmentName)"
              validate_var "vmImageName" "$(vmImageName)"
              
              echo ""
              echo "Validating computed variables:"
              validate_var "buildNumber" "$(buildNumber)"
              validate_var "artifactName" "$(artifactName)"
              
              echo ""
              echo "Variable validation completed"
            displayName: 'Validate required variables'

          - script: |
              echo "=== Variable Troubleshooting Guide ==="
              echo ""
              echo "Common variable issues and solutions:"
              echo ""
              echo "1. Variable not found:"
              echo "   - Check variable name spelling"
              echo "   - Verify variable scope"
              echo "   - Ensure variable is defined before use"
              echo ""
              echo "2. Variable precedence issues:"
              echo "   - Pipeline < Stage < Job < Step"
              echo "   - More specific scopes override broader ones"
              echo ""
              echo "3. Cross-job variables:"
              echo "   - Use output variables with dependencies"
              echo "   - Format: dependencies.JobName.outputs['stepName.variableName']"
              echo ""
              echo "4. Conditional variables:"
              echo "   - Use template expressions: \${{ if condition }}"
              echo "   - Evaluated at compile time"
              echo ""
              echo "5. Runtime variables:"
              echo "   - Use ##vso[task.setvariable] command"
              echo "   - Available in subsequent steps/jobs"
            displayName: 'Variable troubleshooting guide'
```

## Variable Definition Patterns

### Simple Variables
```yaml
variables:
  - name: myVariable
    value: myValue
  - name: numericVariable
    value: 42
  - name: booleanVariable
    value: true
```

### Template Expression Variables
```yaml
variables:
  - name: environmentName
    ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
      value: 'production'
    ${{ else }}:
      value: 'development'
```

### Variable Groups
```yaml
variables:
  - group: 'MyVariableGroup'
  - group: 'DatabaseSettings'
  - name: localVariable
    value: 'localValue'
```

## Working with Variables

### Setting Variables at Runtime
```bash
# In script step
echo "##vso[task.setvariable variable=myVar]myValue"

# Output variable for cross-job usage
echo "##vso[task.setvariable variable=myVar;isOutput=true]myValue"

# Secret variable
echo "##vso[task.setvariable variable=mySecret;issecret=true]secretValue"
```

### Referencing Variables
```yaml
# Basic reference
script: echo "$(myVariable)"

# In conditions
condition: eq(variables['myVariable'], 'expectedValue')

# In expressions
value: '$(prefix)-$(myVariable)-$(suffix)'

# Cross-job reference
value: $[ dependencies.JobName.outputs['stepName.variableName'] ]
```

## Secret Variables

### Defining Secret Variables
```yaml
variables:
  - name: mySecret
    value: $(SecretFromVariableGroup)
  - group: 'SecretsGroup'
```

### Using Secret Variables
```yaml
steps:
  - script: |
      # Secret variables are masked in logs
      echo "Secret value: $(mySecret)"
    env:
      SECRET_VAR: $(mySecret)
```

## Best Practices

### 1. Variable Organization
- **Logical Grouping**: Group related variables together
- **Clear Naming**: Use descriptive and consistent naming conventions
- **Scope Appropriately**: Define variables at the appropriate scope level

### 2. Security
- **Secret Management**: Use secret variables for sensitive data
- **Variable Groups**: Centralize shared secrets in variable groups
- **Least Privilege**: Only expose variables where needed

### 3. Maintainability
- **Documentation**: Comment complex variable logic
- **Validation**: Validate required variables in scripts
- **Default Values**: Provide sensible defaults where possible

### 4. Performance
- **Minimize Scope**: Don't define variables at broader scopes than necessary
- **Efficient References**: Use efficient variable referencing patterns
- **Conditional Definition**: Only define variables when needed

### 5. Testing
- **Variable Testing**: Test pipelines with different variable values
- **Environment Parity**: Keep variable structures consistent across environments
- **Validation Scripts**: Include variable validation in pipelines

## Common Variable Patterns

### Environment Configuration
```yaml
variables:
  - name: apiUrl
    ${{ if eq(variables['environment'], 'prod') }}:
      value: 'https://api.prod.com'
    ${{ else }}:
      value: 'https://api.dev.com'
```

### Dynamic Naming
```yaml
variables:
  - name: resourceName
    value: '$(applicationName)-$(environment)-$(Build.BuildNumber)'
```

### Feature Flags
```yaml
variables:
  - name: enableFeatureX
    value: ${{ eq(variables['Build.SourceBranch'], 'refs/heads/feature/x') }}
```

Understanding variables and their proper usage is essential for creating flexible, maintainable, and secure Azure DevOps pipelines that can adapt to different environments and requirements.
