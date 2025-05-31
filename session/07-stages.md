# Azure DevOps Pipeline Stages

## Overview
Stages are the highest-level organizational units in Azure DevOps Pipelines. They represent major phases in your CI/CD process and provide a way to group related jobs together, implement approval processes, and create logical boundaries in your deployment workflow.

## Explanation
A stage is a collection of related jobs that represents a major phase in your pipeline. Stages run sequentially by default but can be configured to run in parallel. They are essential for implementing complex CI/CD workflows with multiple environments, approval gates, and deployment strategies.

### Key Concepts:
- **Logical Boundaries**: Stages separate different phases of your pipeline
- **Sequential Execution**: Stages run one after another by default
- **Job Grouping**: Each stage contains one or more jobs
- **Approval Gates**: Stages can require manual approvals
- **Environment Mapping**: Stages often represent different environments (dev, test, prod)
- **Deployment Strategies**: Stages support various deployment patterns

## Types of Stages

### 1. Build Stages
- Compile source code
- Run unit tests
- Create artifacts
- Perform static analysis

### 2. Test Stages
- Integration testing
- Performance testing
- Security scanning
- Quality gates

### 3. Deployment Stages
- Deploy to environments
- Run smoke tests
- Database migrations
- Configuration updates

### 4. Approval Stages
- Manual approvals
- Stakeholder sign-offs
- Compliance checks
- Release gates

## Analogy
Think of stages like phases in building a house:

**Construction Project (Pipeline)**:

**Stage 1: Foundation (Build Stage)**:
- Site preparation
- Foundation pouring
- Basic utilities
- Quality inspection
- ✅ Foundation must be solid before moving to next stage

**Stage 2: Structure (Test Stage)**:
- Framing
- Roofing
- Electrical rough-in
- Plumbing rough-in
- ✅ Structure must pass inspection

**Stage 3: Interior (Staging Deployment)**:
- Drywall and painting
- Flooring installation
- Fixture installation
- ✅ Interior work must be complete

**Stage 4: Final Inspection (Production Deployment)**:
- Final walkthrough
- Quality assurance
- Certificate of occupancy
- Handover to owner

Just like construction:
- Each stage must complete successfully before the next begins
- Some stages might require approvals (inspections)
- If a stage fails, you don't proceed to the next
- Some work can happen in parallel within a stage (electrical and plumbing)
- The final product depends on all stages being successful

## Stage Dependencies and Flow Control

### Sequential Stages (Default)
```yaml
stages:
  - stage: Build
  - stage: Test      # Waits for Build to complete
  - stage: Deploy    # Waits for Test to complete
```

### Parallel Stages
```yaml
stages:
  - stage: BuildLinux
    dependsOn: []    # No dependencies
  - stage: BuildWindows
    dependsOn: []    # Runs in parallel with BuildLinux
  - stage: Deploy
    dependsOn: ['BuildLinux', 'BuildWindows']  # Waits for both
```

## Example Workflow YAML

```yaml
# Comprehensive stages configuration examples
name: 'Stages Configuration Demo'

# Trigger
trigger:
  branches:
    include: ['main', 'develop', 'release/*']

# Variables
variables:
  - name: solution
    value: '**/*.sln'
  - name: buildConfiguration
    value: 'Release'
  - name: vmImageName
    value: 'ubuntu-latest'

# Multi-stage pipeline
stages:
  # Stage 1: Build and Unit Test
  - stage: 'Build'
    displayName: 'Build and Unit Test'
    jobs:
      - job: 'BuildJob'
        displayName: 'Build Application'
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              echo "=== Build Stage ==="
              echo "Stage: Build"
              echo "Job: BuildJob"
              echo "Building solution: $(solution)"
              echo "Configuration: $(buildConfiguration)"
              echo "Build started at: $(date)"
            displayName: 'Build information'

          - script: |
              echo "=== Source Code Checkout ==="
              echo "Repository: $(Build.Repository.Name)"
              echo "Branch: $(Build.SourceBranch)"
              echo "Commit: $(Build.SourceVersion)"
              echo "Build Number: $(Build.BuildNumber)"
            displayName: 'Source information'

          - script: |
              echo "=== Build Process ==="
              echo "Step 1: Restoring dependencies..."
              sleep 2
              echo "✅ Dependencies restored"
              
              echo "Step 2: Compiling source code..."
              sleep 3
              echo "✅ Compilation successful"
              
              echo "Step 3: Running unit tests..."
              sleep 2
              echo "✅ Unit tests passed (45/45)"
              
              echo "Step 4: Creating build artifacts..."
              mkdir -p $(Build.ArtifactStagingDirectory)/build
              echo "Build completed at $(date)" > $(Build.ArtifactStagingDirectory)/build/build-info.txt
              echo "✅ Build artifacts created"
            displayName: 'Build and test'

          - publish: $(Build.ArtifactStagingDirectory)/build
            artifact: 'BuildArtifacts'
            displayName: 'Publish build artifacts'

      - job: 'CodeQuality'
        displayName: 'Code Quality Analysis'
        pool:
          vmImage: $(vmImageName)
        dependsOn: []  # Run in parallel with BuildJob
        steps:
          - script: |
              echo "=== Code Quality Analysis ==="
              echo "Running static code analysis..."
              sleep 2
              echo "✅ No critical issues found"
              echo "⚠️  3 minor warnings detected"
              echo "📊 Code coverage: 87%"
              echo "📈 Maintainability index: 85/100"
              
              # Create quality report
              mkdir -p $(Build.ArtifactStagingDirectory)/quality
              cat > $(Build.ArtifactStagingDirectory)/quality/quality-report.json << EOF
              {
                "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
                "coverage": 87,
                "maintainability": 85,
                "criticalIssues": 0,
                "warnings": 3,
                "status": "PASSED"
              }
              EOF
            displayName: 'Static analysis'

          - publish: $(Build.ArtifactStagingDirectory)/quality
            artifact: 'QualityReports'
            displayName: 'Publish quality reports'

  # Stage 2: Integration Testing (runs after Build stage)
  - stage: 'IntegrationTest'
    displayName: 'Integration Testing'
    dependsOn: 'Build'
    condition: succeeded()
    jobs:
      - job: 'IntegrationTests'
        displayName: 'Run Integration Tests'
        pool:
          vmImage: $(vmImageName)
        steps:
          - download: current
            artifact: 'BuildArtifacts'
            displayName: 'Download build artifacts'

          - script: |
              echo "=== Integration Test Stage ==="
              echo "Downloaded artifacts:"
              ls -la $(Pipeline.Workspace)/BuildArtifacts/
              cat $(Pipeline.Workspace)/BuildArtifacts/build-info.txt
            displayName: 'Verify build artifacts'

          - script: |
              echo "=== Integration Test Setup ==="
              echo "Setting up test environment..."
              sleep 2
              echo "✅ Test database initialized"
              echo "✅ Test services started"
              echo "✅ Test data seeded"
            displayName: 'Setup test environment'

          - script: |
              echo "=== Running Integration Tests ==="
              echo "Test suite: API Integration Tests"
              sleep 3
              echo "✅ Authentication tests: 8/8 passed"
              echo "✅ CRUD operation tests: 12/12 passed"
              echo "✅ Business logic tests: 15/15 passed"
              echo "✅ Error handling tests: 6/6 passed"
              echo ""
              echo "Test suite: Database Integration Tests"
              sleep 2
              echo "✅ Connection tests: 3/3 passed"
              echo "✅ Migration tests: 5/5 passed"
              echo "✅ Performance tests: 4/4 passed"
              echo ""
              echo "Total: 53 tests passed, 0 failed"
            displayName: 'Execute integration tests'

          - script: |
              echo "=== Test Environment Cleanup ==="
              echo "Cleaning up test resources..."
              sleep 1
              echo "✅ Test database cleaned"
              echo "✅ Test services stopped"
              echo "✅ Temporary files removed"
            displayName: 'Cleanup test environment'

  # Stage 3: Security and Performance Testing (parallel after Integration)
  - stage: 'SecurityTesting'
    displayName: 'Security Testing'
    dependsOn: 'IntegrationTest'
    jobs:
      - job: 'SecurityScan'
        displayName: 'Security Vulnerability Scan'
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              echo "=== Security Testing Stage ==="
              echo "Running comprehensive security scan..."
              sleep 3
              echo "🔍 Dependency vulnerability scan..."
              sleep 2
              echo "✅ No high-risk vulnerabilities found"
              echo "⚠️  2 medium-risk vulnerabilities found"
              echo "📊 5 low-risk vulnerabilities found"
              echo ""
              echo "🔍 Static application security testing..."
              sleep 2
              echo "✅ No SQL injection vulnerabilities"
              echo "✅ No XSS vulnerabilities"
              echo "✅ Authentication mechanisms secure"
              echo ""
              echo "Security scan completed successfully"
            displayName: 'Security vulnerability assessment'

  - stage: 'PerformanceTesting'
    displayName: 'Performance Testing'
    dependsOn: 'IntegrationTest'
    condition: succeeded()
    jobs:
      - job: 'PerformanceTests'
        displayName: 'Performance Benchmarks'
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              echo "=== Performance Testing Stage ==="
              echo "Running performance benchmarks..."
              sleep 4
              echo "🚀 Load testing results:"
              echo "   - Concurrent users: 100"
              echo "   - Average response time: 150ms"
              echo "   - 95th percentile: 280ms"
              echo "   - Throughput: 850 requests/second"
              echo "   - Error rate: 0.02%"
              echo ""
              echo "🔋 Stress testing results:"
              echo "   - Breaking point: 500 concurrent users"
              echo "   - Memory usage: 512MB peak"
              echo "   - CPU usage: 75% peak"
              echo ""
              echo "✅ Performance targets met"
            displayName: 'Performance benchmarking'

  # Stage 4: Staging Deployment
  - stage: 'StagingDeployment'
    displayName: 'Deploy to Staging'
    dependsOn: ['SecurityTesting', 'PerformanceTesting']
    condition: succeeded()
    variables:
      - name: environmentName
        value: 'Staging'
      - name: deploymentSlot
        value: 'staging'
    jobs:
      - deployment: 'DeployToStaging'
        displayName: 'Deploy to Staging Environment'
        pool:
          vmImage: $(vmImageName)
        environment: 'staging'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: 'BuildArtifacts'
                  displayName: 'Download application artifacts'

                - script: |
                    echo "=== Staging Deployment Stage ==="
                    echo "Environment: $(environmentName)"
                    echo "Deployment Slot: $(deploymentSlot)"
                    echo "Artifacts location: $(Pipeline.Workspace)/BuildArtifacts/"
                  displayName: 'Deployment information'

                - script: |
                    echo "=== Pre-deployment Steps ==="
                    echo "Backing up current staging environment..."
                    sleep 2
                    echo "✅ Staging backup completed"
                    
                    echo "Validating deployment package..."
                    sleep 1
                    echo "✅ Package validation successful"
                    
                    echo "Checking staging environment health..."
                    sleep 1
                    echo "✅ Staging environment is healthy"
                  displayName: 'Pre-deployment validation'

                - script: |
                    echo "=== Application Deployment ==="
                    echo "Deploying application to staging..."
                    sleep 3
                    echo "✅ Application files deployed"
                    
                    echo "Updating configuration..."
                    sleep 1
                    echo "✅ Configuration updated"
                    
                    echo "Running database migrations..."
                    sleep 2
                    echo "✅ Database migrations completed"
                    
                    echo "Starting application services..."
                    sleep 2
                    echo "✅ Services started successfully"
                  displayName: 'Deploy application'

                - script: |
                    echo "=== Post-deployment Verification ==="
                    echo "Running smoke tests..."
                    sleep 2
                    echo "✅ Health check endpoint: OK"
                    echo "✅ Authentication service: OK"
                    echo "✅ Database connectivity: OK"
                    echo "✅ External API connectivity: OK"
                    
                    echo "Verifying application functionality..."
                    sleep 2
                    echo "✅ Critical user workflows: OK"
                    echo "✅ API endpoints responding: OK"
                    
                    echo "Staging deployment completed successfully!"
                  displayName: 'Post-deployment verification'

  # Stage 5: Production Approval
  - stage: 'ProductionApproval'
    displayName: 'Production Approval'
    dependsOn: 'StagingDeployment'
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: 'WaitForApproval'
        displayName: 'Wait for Production Approval'
        pool: server
        timeoutInMinutes: 1440  # 24 hours
        steps:
          - task: ManualValidation@0
            displayName: 'Manual approval for production deployment'
            inputs:
              notifyUsers: |
                user1@company.com
                user2@company.com
              instructions: |
                Please review the staging deployment and approve for production:
                
                Staging Environment: https://staging.myapp.com
                
                Checklist:
                - [ ] Functionality testing completed
                - [ ] Performance acceptable
                - [ ] Security review passed
                - [ ] Business stakeholder sign-off
                
                Build Number: $(Build.BuildNumber)
                Source Branch: $(Build.SourceBranch)
                Commit: $(Build.SourceVersion)
              onTimeout: 'reject'

  # Stage 6: Production Deployment
  - stage: 'ProductionDeployment'
    displayName: 'Deploy to Production'
    dependsOn: 'ProductionApproval'
    condition: succeeded()
    variables:
      - name: environmentName
        value: 'Production'
      - name: deploymentSlot
        value: 'production'
    jobs:
      - deployment: 'DeployToProduction'
        displayName: 'Deploy to Production Environment'
        pool:
          vmImage: $(vmImageName)
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: 'BuildArtifacts'
                  displayName: 'Download application artifacts'

                - script: |
                    echo "=== Production Deployment Stage ==="
                    echo "🚀 PRODUCTION DEPLOYMENT INITIATED"
                    echo "Environment: $(environmentName)"
                    echo "Build: $(Build.BuildNumber)"
                    echo "Commit: $(Build.SourceVersion)"
                    echo "Approved by: $(Build.RequestedFor)"
                  displayName: 'Production deployment info'

                - script: |
                    echo "=== Pre-production Safety Checks ==="
                    echo "Performing final safety validations..."
                    sleep 2
                    echo "✅ Production environment health check"
                    echo "✅ Backup verification completed"
                    echo "✅ Rollback plan confirmed"
                    echo "✅ Monitoring systems active"
                  displayName: 'Pre-production validation'

                - script: |
                    echo "=== Blue-Green Deployment ==="
                    echo "Deploying to green slot..."
                    sleep 4
                    echo "✅ Green deployment completed"
                    
                    echo "Running production smoke tests on green slot..."
                    sleep 3
                    echo "✅ Green slot validation successful"
                    
                    echo "Switching traffic to green slot..."
                    sleep 2
                    echo "✅ Traffic switch completed"
                    
                    echo "Production deployment successful! 🎉"
                  displayName: 'Blue-green deployment'

                - script: |
                    echo "=== Post-deployment Monitoring ==="
                    echo "Monitoring production metrics..."
                    sleep 3
                    echo "📊 Response time: 95ms (excellent)"
                    echo "📊 Error rate: 0.01% (within limits)"
                    echo "📊 CPU usage: 35% (normal)"
                    echo "📊 Memory usage: 60% (normal)"
                    echo "✅ Production deployment monitoring successful"
                  displayName: 'Production monitoring'

  # Stage 7: Post-deployment Validation
  - stage: 'PostDeploymentValidation'
    displayName: 'Post-deployment Validation'
    dependsOn: 'ProductionDeployment'
    condition: succeeded()
    jobs:
      - job: 'ProductionValidation'
        displayName: 'Production Health Validation'
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              echo "=== Post-deployment Validation Stage ==="
              echo "Running comprehensive production validation..."
              sleep 3
              echo "🔍 End-to-end testing:"
              echo "   ✅ User registration flow"
              echo "   ✅ Authentication process"
              echo "   ✅ Core business workflows"
              echo "   ✅ Payment processing"
              echo "   ✅ Reporting functionality"
              echo ""
              echo "🔍 Integration testing:"
              echo "   ✅ External API connectivity"
              echo "   ✅ Database operations"
              echo "   ✅ Email service integration"
              echo "   ✅ Third-party services"
              echo ""
              echo "🎉 Production validation completed successfully!"
            displayName: 'Comprehensive production validation'

      - job: 'NotificationJob'
        displayName: 'Deployment Notifications'
        pool:
          vmImage: $(vmImageName)
        dependsOn: 'ProductionValidation'
        condition: always()
        steps:
          - script: |
              echo "=== Deployment Notifications ==="
              if [ "$(Agent.JobStatus)" = "Succeeded" ]; then
                  echo "✅ Sending success notifications..."
                  echo "📧 Email sent to stakeholders"
                  echo "💬 Slack notification posted"
                  echo "📊 Deployment metrics updated"
                  echo "🎉 Production deployment successful!"
              else
                  echo "❌ Sending failure notifications..."
                  echo "🚨 Alert sent to on-call team"
                  echo "📧 Incident email sent"
                  echo "📞 Escalation triggered"
              fi
            displayName: 'Send deployment notifications'
```

## Stage Conditions and Dependencies

### Conditional Stages
```yaml
stages:
  - stage: Deploy
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

  - stage: SecurityScan
    condition: or(eq(variables['Build.Reason'], 'PullRequest'), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
```

### Complex Dependencies
```yaml
stages:
  - stage: BuildLinux
  - stage: BuildWindows
  - stage: BuildMacOS
  - stage: Deploy
    dependsOn: ['BuildLinux', 'BuildWindows', 'BuildMacOS']
    condition: |
      and(
        succeeded('BuildLinux'),
        succeeded('BuildWindows'),
        succeeded('BuildMacOS')
      )
```

## Deployment Strategies in Stages

### Blue-Green Deployment
```yaml
- stage: BlueGreenDeploy
  jobs:
    - deployment: DeployBlue
      environment: production-blue
      strategy:
        runOnce:
          deploy:
            steps:
              - script: echo "Deploy to blue slot"
    
    - job: SwitchTraffic
      dependsOn: DeployBlue
      steps:
        - script: echo "Switch traffic to blue"
```

### Canary Deployment
```yaml
- stage: CanaryDeploy
  jobs:
    - deployment: CanaryDeployment
      environment: production
      strategy:
        canary:
          increments: [10, 25, 50, 100]
          deploy:
            steps:
              - script: echo "Canary deployment"
```

## Best Practices

### 1. Stage Organization
- **Logical Separation**: Group related activities in the same stage
- **Clear Naming**: Use descriptive stage names that reflect their purpose
- **Appropriate Granularity**: Balance between too many and too few stages

### 2. Dependencies and Flow
- **Minimize Dependencies**: Only add dependencies when necessary
- **Parallel Execution**: Run independent stages in parallel
- **Fail-Fast**: Structure stages to fail quickly when issues are detected

### 3. Environment Management
- **Environment Progression**: Follow a clear environment promotion path
- **Approval Gates**: Use manual validations for critical stages
- **Rollback Strategy**: Plan for rollback scenarios

### 4. Monitoring and Observability
- **Stage Metrics**: Track stage success rates and durations
- **Error Handling**: Implement proper error handling and notifications
- **Audit Trail**: Maintain clear deployment history

### 5. Security and Compliance
- **Approval Processes**: Implement required approval workflows
- **Secret Management**: Use secure variables for sensitive data
- **Compliance Checks**: Include compliance validation in appropriate stages

## Common Stage Patterns

### CI/CD Pipeline Pattern
```yaml
stages:
  - stage: CI
    jobs: [Build, UnitTest, StaticAnalysis]
  
  - stage: QA
    jobs: [IntegrationTest, SecurityScan, PerformanceTest]
  
  - stage: Staging
    jobs: [DeployToStaging, SmokeTest]
  
  - stage: Production
    jobs: [DeployToProduction, HealthCheck]
```

### Feature Branch Pattern
```yaml
stages:
  - stage: Build
    condition: always()
  
  - stage: Test
    condition: succeeded()
  
  - stage: DeployFeature
    condition: startsWith(variables['Build.SourceBranch'], 'refs/heads/feature/')
  
  - stage: DeployMain
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
```

### Multi-Environment Pattern
```yaml
stages:
  - stage: BuildAndTest
  
  - stage: DeployDev
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/develop')
  
  - stage: DeployTest
    condition: startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')
  
  - stage: DeployProd
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
```

Understanding stages and their configuration is essential for creating well-structured, maintainable, and robust CI/CD pipelines that support complex deployment scenarios and organizational requirements.
