# Setting Up a Linux Self-Hosted Agent in Azure DevOps

## Overview
Setting up a self-hosted Linux agent gives you complete control over the build environment, allows access to internal networks, and provides the ability to install custom tools and configurations. This guide walks through the complete process of setting up and configuring a Linux self-hosted agent.

## Explanation
A self-hosted agent is a machine (physical or virtual) that you configure and maintain to run Azure DevOps pipeline jobs. Unlike Microsoft-hosted agents, self-hosted agents provide:

- **Persistent environment**: State persists between builds
- **Custom software**: Install any tools or dependencies you need
- **Network access**: Connect to internal resources and services
- **Cost control**: No per-minute charges for job execution
- **Performance**: Choose your hardware specifications
- **Security**: Full control over the security configuration

## Analogy
Setting up a self-hosted agent is like setting up your own workshop compared to renting a shared workspace:

**Shared Workspace (Microsoft-hosted)**:
- Pre-equipped with standard tools
- Clean slate every time you use it
- Pay per hour
- Limited customization
- Can't leave your projects overnight

**Your Own Workshop (Self-hosted)**:
- Install exactly the tools you need
- Arrange everything the way you want
- Keep your projects and materials between sessions
- One-time setup cost, then just utilities
- Complete control over security and access
- Can work on specialized projects that need special equipment

## Prerequisites

Before setting up a self-hosted agent, ensure you have:

1. **Linux Machine**: Ubuntu 18.04+, CentOS 7+, RHEL 7+, or similar
2. **Azure DevOps Organization**: With appropriate permissions
3. **Agent Pool**: Created in Azure DevOps (or use the default pool)
4. **Personal Access Token (PAT)**: With Agent Pools (read, manage) scope
5. **Network Access**: Internet connectivity and access to dev.azure.com
6. **User Account**: With sudo privileges for initial setup

## Step-by-Step Setup Process

### Step 1: Prepare the Linux Environment

```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git unzip

# Install .NET runtime (required for the agent)
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-runtime-6.0

# Create a user for the agent (optional but recommended)
sudo useradd -m -s /bin/bash azureagent
sudo usermod -aG sudo azureagent
```

### Step 2: Download and Configure the Agent

```bash
# Switch to the agent user
sudo su - azureagent

# Create agent directory
mkdir ~/azagent && cd ~/azagent

# Download the agent (check Azure DevOps for the latest version)
curl -O https://vstsagentpackage.azureedge.net/agent/3.232.0/vsts-agent-linux-x64-3.232.0.tar.gz

# Extract the agent
tar zxvf vsts-agent-linux-x64-3.232.0.tar.gz

# Install dependencies
sudo ./bin/installdependencies.sh
```

### Step 3: Configure the Agent

```bash
# Run the configuration script
./config.sh

# You'll be prompted for:
# - Server URL: https://dev.azure.com/{your-organization}
# - Authentication type: Choose "PAT"
# - Personal access token: Enter your PAT
# - Agent pool: Enter pool name (e.g., "Default" or your custom pool)
# - Agent name: Give your agent a descriptive name
# - Work folder: Accept default or specify custom path
# - Run as service: Choose 'Y' for production environments
```

### Step 4: Install the Agent as a Service

```bash
# Install the service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check service status
sudo ./svc.sh status
```

## Example Workflow YAML

```yaml
# Pipeline demonstrating self-hosted Linux agent usage
name: 'Self-Hosted Linux Agent Demo'

# Trigger configuration
trigger:
  branches:
    include: ['main', 'develop']

# Variables
variables:
  - name: agentPool
    value: 'MyCompany-Linux-Pool'
  - name: buildConfiguration
    value: 'Release'

# Pipeline stages
stages:
  # Stage 1: Basic agent verification
  - stage: 'AgentVerification'
    displayName: 'Verify Self-Hosted Agent'
    jobs:
      - job: 'VerifyAgent'
        displayName: 'Verify Agent Configuration'
        pool:
          name: $(agentPool)
          demands:
            - Agent.OS -equals Linux
        steps:
          - script: |
              echo "=== Self-Hosted Agent Verification ==="
              echo "Agent Name: $(Agent.Name)"
              echo "Agent OS: $(Agent.OS)"
              echo "Agent Version: $(Agent.Version)"
              echo "Working Directory: $(Agent.WorkFolder)"
              echo "Build Directory: $(Agent.BuildDirectory)"
              echo "Pool Name: $(agentPool)"
              echo ""
              
              echo "=== System Information ==="
              echo "Hostname: $(hostname)"
              echo "OS Release: $(cat /etc/os-release | grep PRETTY_NAME)"
              echo "Kernel: $(uname -r)"
              echo "Architecture: $(uname -m)"
              echo "CPU Cores: $(nproc)"
              echo "Memory: $(free -h | grep Mem)"
              echo "Disk Space: $(df -h / | tail -1)"
              echo ""
              
              echo "=== Network Configuration ==="
              echo "IP Address: $(hostname -I | awk '{print $1}')"
              echo "DNS Servers: $(cat /etc/resolv.conf | grep nameserver)"
            displayName: 'Display agent and system information'

  # Stage 2: Custom tool verification
  - stage: 'CustomTools'
    displayName: 'Verify Custom Tools'
    dependsOn: 'AgentVerification'
    jobs:
      - job: 'ToolVerification'
        displayName: 'Verify Installed Tools'
        pool:
          name: $(agentPool)
          demands:
            - Agent.OS -equals Linux
        steps:
          - script: |
              echo "=== Standard Development Tools ==="
              tools=("git" "curl" "wget" "unzip" "tar" "make" "gcc")
              
              for tool in "${tools[@]}"; do
                  if command -v $tool &> /dev/null; then
                      version=$($tool --version 2>/dev/null | head -1 || echo "Version unavailable")
                      echo "✅ $tool: $version"
                  else
                      echo "❌ $tool: Not installed"
                  fi
              done
            displayName: 'Check standard tools'

          - script: |
              echo "=== Development Runtimes ==="
              
              # Check .NET
              if command -v dotnet &> /dev/null; then
                  echo "✅ .NET SDK:"
                  dotnet --version
                  echo "   Available SDKs:"
                  dotnet --list-sdks | sed 's/^/   /'
              else
                  echo "❌ .NET SDK: Not installed"
              fi
              echo ""
              
              # Check Node.js
              if command -v node &> /dev/null; then
                  echo "✅ Node.js: $(node --version)"
                  echo "✅ npm: $(npm --version)"
              else
                  echo "❌ Node.js: Not installed"
              fi
              echo ""
              
              # Check Python
              if command -v python3 &> /dev/null; then
                  echo "✅ Python: $(python3 --version)"
                  if command -v pip3 &> /dev/null; then
                      echo "✅ pip: $(pip3 --version)"
                  fi
              else
                  echo "❌ Python: Not installed"
              fi
              echo ""
              
              # Check Docker
              if command -v docker &> /dev/null; then
                  echo "✅ Docker: $(docker --version)"
                  if docker info &> /dev/null; then
                      echo "   Docker daemon is running"
                  else
                      echo "   ⚠️  Docker daemon is not running"
                  fi
              else
                  echo "❌ Docker: Not installed"
              fi
            displayName: 'Check development runtimes'

  # Stage 3: Build and test capabilities
  - stage: 'BuildCapabilities'
    displayName: 'Test Build Capabilities'
    dependsOn: 'CustomTools'
    jobs:
      - job: 'DotNetBuild'
        displayName: '.NET Build Test'
        pool:
          name: $(agentPool)
          demands:
            - Agent.OS -equals Linux
            - dotnet
        steps:
          - script: |
              echo "=== .NET Build Test ==="
              
              # Create a simple .NET project
              mkdir -p testapp && cd testapp
              dotnet new console --force
              
              # Modify Program.cs
              cat > Program.cs << 'EOF'
              using System;
              
              namespace TestApp
              {
                  class Program
                  {
                      static void Main(string[] args)
                      {
                          Console.WriteLine($"Hello from self-hosted agent!");
                          Console.WriteLine($"Build time: {DateTime.Now}");
                          Console.WriteLine($"Running on: {Environment.OSVersion}");
                          Console.WriteLine($"Agent: {Environment.GetEnvironmentVariable("AGENT_NAME")}");
                      }
                  }
              }
              EOF
              
              # Build the project
              echo "Building .NET project..."
              dotnet build --configuration $(buildConfiguration) --verbosity minimal
              
              # Run the application
              echo "Running the application..."
              dotnet run --configuration $(buildConfiguration)
              
              # Clean up
              cd .. && rm -rf testapp
            displayName: 'Build and run .NET application'

      - job: 'NodeJSBuild'
        displayName: 'Node.js Build Test'
        pool:
          name: $(agentPool)
          demands:
            - Agent.OS -equals Linux
            - node
        condition: succeeded()
        steps:
          - script: |
              echo "=== Node.js Build Test ==="
              
              # Create a simple Node.js project
              mkdir -p nodeapp && cd nodeapp
              
              # Create package.json
              cat > package.json << 'EOF'
              {
                "name": "test-app",
                "version": "1.0.0",
                "description": "Test application for self-hosted agent",
                "main": "app.js",
                "scripts": {
                  "start": "node app.js",
                  "test": "echo \"Test passed\" && exit 0"
                }
              }
              EOF
              
              # Create app.js
              cat > app.js << 'EOF'
              console.log('Hello from self-hosted agent!');
              console.log(`Build time: ${new Date().toISOString()}`);
              console.log(`Node.js version: ${process.version}`);
              console.log(`Platform: ${process.platform}`);
              console.log(`Agent: ${process.env.AGENT_NAME}`);
              EOF
              
              # Install dependencies (if any)
              echo "Installing Node.js dependencies..."
              npm install
              
              # Run tests
              echo "Running tests..."
              npm test
              
              # Run the application
              echo "Running the application..."
              npm start
              
              # Clean up
              cd .. && rm -rf nodeapp
            displayName: 'Build and run Node.js application'

  # Stage 4: Internal network access test
  - stage: 'NetworkAccess'
    displayName: 'Test Network Access'
    dependsOn: 'BuildCapabilities'
    jobs:
      - job: 'NetworkTest'
        displayName: 'Test Internal Network Access'
        pool:
          name: $(agentPool)
        steps:
          - script: |
              echo "=== Network Connectivity Test ==="
              
              # Test external connectivity
              echo "Testing external connectivity:"
              if ping -c 3 google.com &> /dev/null; then
                  echo "✅ External connectivity: OK"
              else
                  echo "❌ External connectivity: Failed"
              fi
              
              # Test Azure DevOps connectivity
              echo "Testing Azure DevOps connectivity:"
              if curl -s https://dev.azure.com &> /dev/null; then
                  echo "✅ Azure DevOps connectivity: OK"
              else
                  echo "❌ Azure DevOps connectivity: Failed"
              fi
              
              # Test internal network (example - replace with your internal hosts)
              echo "Testing internal network access:"
              internal_hosts=("internal.company.com" "database.local" "api.internal")
              
              for host in "${internal_hosts[@]}"; do
                  if ping -c 1 -W 2 "$host" &> /dev/null; then
                      echo "✅ $host: Accessible"
                  else
                      echo "⚠️  $host: Not accessible (may be expected)"
                  fi
              done
              
              # Check available network interfaces
              echo ""
              echo "Network interfaces:"
              ip addr show | grep -E '^[0-9]+:|inet ' | sed 's/^/  /'
            displayName: 'Test network connectivity'

  # Stage 5: Performance and resource monitoring
  - stage: 'Performance'
    displayName: 'Performance Monitoring'
    dependsOn: 'NetworkAccess'
    jobs:
      - job: 'PerformanceTest'
        displayName: 'Performance and Resource Test'
        pool:
          name: $(agentPool)
        steps:
          - script: |
              echo "=== Performance Test ==="
              start_time=$(date +%s)
              
              # CPU test
              echo "Running CPU intensive task..."
              seq 1 100000 | factor > /dev/null
              
              # Memory test
              echo "Testing memory allocation..."
              python3 -c "
              import sys
              data = [i for i in range(1000000)]
              print(f'Allocated memory for {len(data)} integers')
              "
              
              # Disk I/O test
              echo "Testing disk I/O..."
              dd if=/dev/zero of=testfile bs=1M count=100 &> /dev/null
              sync
              dd if=testfile of=/dev/null bs=1M &> /dev/null
              rm testfile
              
              end_time=$(date +%s)
              duration=$((end_time - start_time))
              
              echo "Performance test completed in $duration seconds"
              
              # Resource usage
              echo ""
              echo "Current resource usage:"
              echo "Memory: $(free -h | grep Mem)"
              echo "CPU Load: $(uptime | awk -F'load average:' '{ print $2 }')"
              echo "Disk Usage: $(df -h / | tail -1)"
            displayName: 'Run performance tests'
```

## Agent Management Commands

### Service Management
```bash
# Check agent status
sudo ./svc.sh status

# Start the agent service
sudo ./svc.sh start

# Stop the agent service
sudo ./svc.sh stop

# Restart the agent service
sudo ./svc.sh restart

# Uninstall the service
sudo ./svc.sh uninstall
```

### Configuration Management
```bash
# Reconfigure the agent
./config.sh remove  # Remove current configuration
./config.sh          # Configure again

# Update the agent
./run.sh --once  # Test run
```

## Security Considerations

### 1. User Permissions
```bash
# Create dedicated user with minimal permissions
sudo useradd -m -s /bin/bash azureagent
sudo usermod -aG docker azureagent  # Only if Docker access needed
```

### 2. Network Security
- Configure firewall rules
- Limit outbound connections if necessary
- Use VPN for internal network access

### 3. File System Security
```bash
# Set proper permissions on agent directory
chmod 755 ~/azagent
chown -R azureagent:azureagent ~/azagent
```

### 4. Token Security
- Use PATs with minimal required scopes
- Rotate tokens regularly
- Store tokens securely

## Monitoring and Maintenance

### 1. Log Monitoring
```bash
# Agent logs location
tail -f ~/azagent/_diag/Agent_*.log

# System logs
sudo journalctl -u vsts.agent.{organization}.{pool}.{agent}.service -f
```

### 2. Health Checks
```bash
# Create health check script
cat > agent_health_check.sh << 'EOF'
#!/bin/bash
SERVICE_NAME="vsts.agent.myorg.mypool.myagent.service"

if systemctl is-active --quiet $SERVICE_NAME; then
    echo "✅ Agent service is running"
else
    echo "❌ Agent service is not running"
    sudo systemctl start $SERVICE_NAME
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    echo "⚠️  Disk usage is high: ${DISK_USAGE}%"
fi

# Check memory
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ $MEMORY_USAGE -gt 90 ]; then
    echo "⚠️  Memory usage is high: ${MEMORY_USAGE}%"
fi
EOF

chmod +x agent_health_check.sh
```

### 3. Automated Updates
```bash
# Create update script
cat > update_agent.sh << 'EOF'
#!/bin/bash
cd ~/azagent

# Stop the service
sudo ./svc.sh stop

# Download latest agent
LATEST_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
wget "https://vstsagentpackage.azureedge.net/agent/${LATEST_VERSION}/vsts-agent-linux-x64-${LATEST_VERSION}.tar.gz"

# Backup current installation
cp -r ~/azagent ~/azagent.backup.$(date +%Y%m%d)

# Extract new version
tar zxvf "vsts-agent-linux-x64-${LATEST_VERSION}.tar.gz"

# Start the service
sudo ./svc.sh start

echo "Agent updated to version $LATEST_VERSION"
EOF

chmod +x update_agent.sh
```

## Troubleshooting Common Issues

### 1. Agent Not Connecting
- Check network connectivity to dev.azure.com
- Verify PAT permissions and expiration
- Check firewall settings
- Verify agent pool permissions

### 2. Service Not Starting
- Check service logs: `sudo journalctl -u vsts.agent.*`
- Verify user permissions
- Check dependencies installation

### 3. Build Failures
- Check agent capabilities match job demands
- Verify tools and dependencies are installed
- Check file permissions in work directory

### 4. Performance Issues
- Monitor resource usage during builds
- Check for disk space issues
- Consider agent scaling for high load

## Best Practices

1. **Dedicated Machine**: Use a dedicated machine for the agent when possible
2. **Regular Updates**: Keep the agent and OS updated
3. **Monitoring**: Implement health checks and monitoring
4. **Backup**: Backup agent configuration and custom tools
5. **Security**: Follow security best practices for access control
6. **Documentation**: Document your agent configuration and customizations
7. **Testing**: Test agent capabilities regularly
8. **Scaling**: Plan for multiple agents if needed for parallel builds

Setting up a self-hosted Linux agent provides powerful capabilities for your CI/CD pipelines while giving you complete control over the build environment.
