# Azure DevOps Pipeline Agents

## Overview
Agents are the workhorses of Azure DevOps Pipelines. They are computing environments where your pipeline jobs execute. Understanding agents is crucial for optimizing performance, managing costs, and ensuring your pipelines run in the right environment with the necessary tools and permissions.

## Explanation
An agent is a computing resource (virtual machine, container, or physical machine) that runs one job at a time. When you run a pipeline, Azure DevOps finds an available agent, downloads your source code to that agent, and runs the jobs of your pipeline on that agent.

### Key Concepts:
- **Agent Pool**: A collection of agents that share common characteristics
- **Agent Capabilities**: Tools, software, and configurations available on an agent
- **Agent Demands**: Requirements specified by your pipeline that an agent must meet
- **Agent Queue**: The mechanism that matches jobs to available agents
- **Parallel Jobs**: The number of jobs that can run simultaneously in your organization

## Types of Agents

### 1. Microsoft-Hosted Agents (Azure Cloud Agents)
- Managed by Microsoft
- Fresh virtual machine for each job
- Pre-installed software and tools
- No maintenance required
- Limited customization
- Usage-based pricing

### 2. Self-Hosted Agents
- Managed by you
- Persistent environment
- Full customization control
- Can access private networks
- One-time setup cost
- Requires maintenance

## Analogy
Think of agents like rental kitchens vs. your home kitchen:

**Microsoft-Hosted Agents (Rental Kitchens)**:
- Like renting a fully equipped commercial kitchen for each cooking session
- Clean, fresh environment every time
- All standard equipment provided (ovens, mixers, basic ingredients)
- No maintenance worries - just show up and cook
- Pay per use
- Can't customize the layout or add special equipment
- Perfect for standard recipes

**Self-Hosted Agents (Home Kitchen)**:
- Like having your own customized kitchen
- You control all the equipment and tools
- Can add specialized appliances (pizza oven, ice cream maker)
- Keep ingredients in your pantry between cooking sessions
- Access to your private recipe collection (internal networks)
- You handle all maintenance and upgrades
- One-time setup cost, then just utility bills
- Perfect for specialized or frequent cooking

## Microsoft-Hosted Agents (Azure Cloud Agents)

### Available Images:
- **ubuntu-latest** (Ubuntu 22.04)
- **windows-latest** (Windows Server 2022)
- **macOS-latest** (macOS 12)
- **ubuntu-20.04**
- **windows-2019**
- **macOS-11**

### Characteristics:
- 2-core CPU, 7 GB RAM, 14 GB SSD
- Clean environment for each job
- Pre-installed software and tools
- Automatic updates
- No persistent storage between jobs
- Internet connectivity
- Limited job timeout (360 minutes for public projects, 60 minutes for private)

## Self-Hosted Agents

### Benefits:
- **Custom Software**: Install any tools you need
- **Network Access**: Access to internal resources
- **Performance**: Choose your hardware specifications
- **Persistence**: Keep data between builds
- **Cost Control**: No per-minute charges for long-running jobs
- **Security**: Full control over the environment

### Considerations:
- **Maintenance**: You manage updates and security
- **Setup Time**: Initial configuration required
- **Scaling**: Manual capacity management
- **Availability**: You ensure uptime

## Example Workflow YAML

```yaml
# Comprehensive agent configuration examples
name: 'Agent Configuration Examples'

# Trigger
trigger:
  branches:
    include: ['main', 'develop']

# Variables
variables:
  - name: agentType
    value: 'undefined'

# Multiple stages demonstrating different agent types
stages:
  # Stage 1: Microsoft-hosted Ubuntu agent
  - stage: 'UbuntuBuild'
    displayName: 'Build on Ubuntu (Microsoft-hosted)'
    jobs:
      - job: 'UbuntuJob'
        displayName: 'Ubuntu Build Job'
        pool:
          vmImage: 'ubuntu-latest'
        variables:
          agentType: 'Microsoft-hosted Ubuntu'
        steps:
          - script: |
              echo "=== Agent Information ==="
              echo "Agent Type: $(agentType)"
              echo "Agent Name: $(Agent.Name)"
              echo "Agent OS: $(Agent.OS)"
              echo "Agent Version: $(Agent.Version)"
              echo "Working Directory: $(Agent.WorkFolder)"
              echo "Build Directory: $(Agent.BuildDirectory)"
              echo ""
              echo "=== System Information ==="
              uname -a
              lsb_release -a
              nproc
              free -h
              df -h
            displayName: 'Display agent and system information'

          - script: |
              echo "=== Pre-installed Software ==="
              echo "Docker version:"
              docker --version
              echo ""
              echo "Node.js version:"
              node --version
              echo ""
              echo "Python version:"
              python3 --version
              echo ""
              echo "Git version:"
              git --version
              echo ""
              echo "Available .NET SDKs:"
              dotnet --list-sdks
            displayName: 'Show pre-installed software'

  # Stage 2: Microsoft-hosted Windows agent
  - stage: 'WindowsBuild'
    displayName: 'Build on Windows (Microsoft-hosted)'
    dependsOn: []  # Run in parallel with UbuntuBuild
    jobs:
      - job: 'WindowsJob'
        displayName: 'Windows Build Job'
        pool:
          vmImage: 'windows-latest'
        variables:
          agentType: 'Microsoft-hosted Windows'
        steps:
          - powershell: |
              Write-Host "=== Agent Information ==="
              Write-Host "Agent Type: $(agentType)"
              Write-Host "Agent Name: $(Agent.Name)"
              Write-Host "Agent OS: $(Agent.OS)"
              Write-Host "Agent Version: $(Agent.Version)"
              Write-Host "Working Directory: $(Agent.WorkFolder)"
              Write-Host "Build Directory: $(Agent.BuildDirectory)"
              Write-Host ""
              Write-Host "=== System Information ==="
              Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory
              Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores
            displayName: 'Display agent and system information'

          - powershell: |
              Write-Host "=== Pre-installed Software ==="
              Write-Host "PowerShell version:"
              $PSVersionTable.PSVersion
              Write-Host ""
              Write-Host "Visual Studio version:"
              if (Get-Command "vswhere" -ErrorAction SilentlyContinue) {
                  & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -property displayName
              }
              Write-Host ""
              Write-Host "Available .NET SDKs:"
              dotnet --list-sdks
            displayName: 'Show pre-installed software'

  # Stage 3: Self-hosted agent (example configuration)
  - stage: 'SelfHostedBuild'
    displayName: 'Build on Self-hosted Agent'
    dependsOn: []  # Run in parallel
    jobs:
      - job: 'SelfHostedJob'
        displayName: 'Self-hosted Build Job'
        pool:
          name: 'MyCompany-Linux-Pool'  # Your self-hosted pool name
          demands:
            - Agent.OS -equals Linux
            - docker
            - customTool
        variables:
          agentType: 'Self-hosted Linux'
        steps:
          - script: |
              echo "=== Self-hosted Agent Information ==="
              echo "Agent Type: $(agentType)"
              echo "Agent Name: $(Agent.Name)"
              echo "Agent OS: $(Agent.OS)"
              echo "Pool Name: MyCompany-Linux-Pool"
              echo "Working Directory: $(Agent.WorkFolder)"
              echo ""
              echo "=== Custom Environment ==="
              echo "Custom tools and configurations:"
              if command -v customTool &> /dev/null; then
                  echo "✅ Custom tool is available"
                  customTool --version
              else
                  echo "❌ Custom tool not found"
              fi
              
              echo ""
              echo "Internal network access test:"
              if ping -c 1 internal.company.com &> /dev/null; then
                  echo "✅ Can access internal resources"
              else
                  echo "❌ Cannot access internal resources"
              fi
            displayName: 'Display self-hosted agent capabilities'

  # Stage 4: Agent capability demonstration
  - stage: 'AgentCapabilities'
    displayName: 'Agent Capabilities and Demands'
    dependsOn: ['UbuntuBuild', 'WindowsBuild']
    jobs:
      - job: 'CapabilityTest'
        displayName: 'Test Agent Capabilities'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: |
              echo "=== Testing Agent Capabilities ==="
              echo "Checking for required tools..."
              
              tools=("git" "docker" "node" "python3" "dotnet")
              
              for tool in "${tools[@]}"; do
                  if command -v $tool &> /dev/null; then
                      echo "✅ $tool is available"
                      case $tool in
                          "git")
                              git --version
                              ;;
                          "docker")
                              docker --version
                              ;;
                          "node")
                              node --version
                              ;;
                          "python3")
                              python3 --version
                              ;;
                          "dotnet")
                              dotnet --version
                              ;;
                      esac
                  else
                      echo "❌ $tool is not available"
                  fi
                  echo ""
              done
            displayName: 'Check tool availability'

  # Stage 5: Performance comparison
  - stage: 'PerformanceTest'
    displayName: 'Agent Performance Comparison'
    dependsOn: ['AgentCapabilities']
    jobs:
      - job: 'UbuntuPerformance'
        displayName: 'Ubuntu Agent Performance'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: |
              echo "=== Performance Test on Ubuntu Agent ==="
              start_time=$(date +%s)
              
              echo "CPU Test: Calculating prime numbers..."
              seq 1 10000 | factor | wc -l > /dev/null
              
              echo "I/O Test: Creating and reading files..."
              for i in {1..100}; do
                  echo "Test data $i" > "test_file_$i.txt"
              done
              cat test_*.txt > combined.txt
              rm test_*.txt combined.txt
              
              end_time=$(date +%s)
              duration=$((end_time - start_time))
              echo "Performance test completed in $duration seconds"
            displayName: 'Performance benchmark'

      - job: 'WindowsPerformance'
        displayName: 'Windows Agent Performance'
        pool:
          vmImage: 'windows-latest'
        steps:
          - powershell: |
              Write-Host "=== Performance Test on Windows Agent ==="
              $start_time = Get-Date
              
              Write-Host "CPU Test: Calculating numbers..."
              1..10000 | ForEach-Object { [Math]::Sqrt($_) } | Measure-Object | Out-Null
              
              Write-Host "I/O Test: Creating and reading files..."
              1..100 | ForEach-Object {
                  "Test data $_" | Out-File "test_file_$_.txt"
              }
              Get-Content test_*.txt | Out-File combined.txt
              Remove-Item test_*.txt, combined.txt
              
              $end_time = Get-Date
              $duration = ($end_time - $start_time).TotalSeconds
              Write-Host "Performance test completed in $duration seconds"
            displayName: 'Performance benchmark'
```

## Agent Pool Configuration

### Microsoft-Hosted Pool Usage
```yaml
pool:
  vmImage: 'ubuntu-latest'
```

### Self-Hosted Pool Usage
```yaml
pool:
  name: 'MyCompany-Pool'
  demands:
    - Agent.OS -equals Linux
    - docker
    - kubectl
```

### Agent Demands
```yaml
pool:
  name: 'MyPool'
  demands:
    - msbuild
    - visualstudio
    - Agent.ComputerName -equals MySpecificAgent
```

## Best Practices

### For Microsoft-Hosted Agents:
1. **Choose the right image**: Select the OS that matches your application
2. **Minimize job time**: Keep jobs under timeout limits
3. **Use caching**: Cache dependencies to speed up builds
4. **Parallel jobs**: Break work into parallel jobs when possible

### For Self-Hosted Agents:
1. **Regular maintenance**: Keep agents updated and secure
2. **Monitoring**: Monitor agent health and performance
3. **Scaling**: Plan for peak demand periods
4. **Security**: Implement proper access controls and network security
5. **Backup**: Ensure agent configurations are documented and backed up

### General Best Practices:
1. **Agent capabilities**: Understand what tools are available on each agent type
2. **Pool strategy**: Use different pools for different types of work
3. **Cost optimization**: Choose the most cost-effective agent for each job
4. **Testing**: Test pipelines on multiple agent types when targeting multiple platforms

## Common Scenarios

- **Cross-platform builds**: Use multiple agent types for different OS targets
- **Security scanning**: Use self-hosted agents for accessing private security tools
- **Performance testing**: Use self-hosted agents with specific hardware configurations
- **Internal deployments**: Use self-hosted agents with network access to internal systems
- **Cost optimization**: Use self-hosted agents for long-running or frequent jobs

Understanding agents and choosing the right type for your workload is essential for building efficient, secure, and cost-effective CI/CD pipelines.
