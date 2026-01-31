# Azure DevOps Pipeline Workflow Training

A comprehensive guide to mastering Azure DevOps YAML pipelines with practical examples, real-world scenarios, and best practices.

## 📚 Complete Lesson Series

This training series covers all essential aspects of Azure DevOps pipelines through 12 detailed lessons, each with explanations, analogies, and comprehensive YAML examples.

### Core Pipeline Concepts

| Lesson | Topic | Description | Key Concepts |
|--------|-------|-------------|--------------|
| [01](./01-syntax-structure.md) | **Syntax & Structure** | YAML fundamentals and pipeline anatomy | Basic YAML, pipeline components, recipe analogy |
| [02](./02-triggers.md) | **Triggers** | All trigger types and configurations | CI, PR, scheduled, pipeline, manual triggers |
| [03](./03-agents.md) | **Agents** | Microsoft-hosted vs self-hosted agents | Agent types, pools, capabilities, kitchen analogy |
| [04](./04-self-hosted-agent-setup.md) | **Self-Hosted Agent Setup** | Complete Linux agent installation guide | Agent installation, registration, configuration |

### Pipeline Organization

| Lesson | Topic | Description | Key Concepts |
|--------|-------|-------------|--------------|
| [05](./05-jobs.md) | **Jobs** | Job types, dependencies, and strategies | Job organization, matrix jobs, construction analogy |
| [06](./06-steps.md) | **Steps** | All step types and error handling | Task steps, script steps, conditions, recipe analogy |
| [07](./07-stages.md) | **Stages** | Stage organization and deployment strategies | Stage dependencies, approvals, house construction analogy |

### Advanced Features

| Lesson | Topic | Description | Key Concepts |
|--------|-------|-------------|--------------|
| [08](./08-variables.md) | **Variables** | Variable types, scopes, and security | Pipeline variables, variable groups, runtime variables |
| [09](./09-conditions.md) | **Conditions** | Pipeline conditions and conditional logic | Built-in conditions, expressions, traffic light analogy |
| [10](./10-loops.md) | **Loops & Matrix** | Looping constructs and matrix strategies | Matrix jobs, parallel execution, assembly line analogy |
| [11](./11-functions.md) | **Functions** | Built-in functions and expressions | String functions, logic functions, smart assistant analogy |
| [12](./12-tasks.md) | **Tasks** | Azure DevOps tasks and custom development | Built-in tasks, custom tasks, workshop analogy |

## 🎯 Learning Path

### **Beginner (Start Here)**
1. [Syntax & Structure](./01-syntax-structure.md) - Learn YAML basics
2. [Triggers](./02-triggers.md) - Understand when pipelines run
3. [Steps](./06-steps.md) - Master the building blocks

### **Intermediate**
4. [Jobs](./05-jobs.md) - Organize work into jobs
5. [Stages](./07-stages.md) - Structure complex deployments
6. [Variables](./08-variables.md) - Manage configuration and secrets

### **Advanced**
7. [Agents](./03-agents.md) - Choose and configure execution environments
8. [Self-Hosted Agents](./04-self-hosted-agent-setup.md) - Set up custom agents
9. [Conditions](./09-conditions.md) - Add intelligent logic
10. [Loops & Matrix](./10-loops.md) - Scale testing and deployment
11. [Functions](./11-functions.md) - Create dynamic pipelines
12. [Tasks](./12-tasks.md) - Master built-in and custom tasks

## 🛠️ Practical Examples

Each lesson includes:
- **📖 Comprehensive explanations** with real-world context
- **🔗 Relatable analogies** to simplify complex concepts
- **💻 Complete YAML examples** ready for implementation
- **✅ Best practices** and troubleshooting tips
- **🔧 Hands-on exercises** and practical scenarios

## 🌟 Key Features

- **Progressive Learning**: Concepts build upon each other naturally
- **Real-World Focus**: Examples based on actual enterprise scenarios
- **Multiple Technologies**: .NET, Node.js, Python, containers, and more
- **Security First**: Secure coding practices and vulnerability scanning
- **DevOps Culture**: Emphasis on collaboration and automation

## 📖 Quick Reference

### Essential Pipeline Structure
```yaml
# Basic pipeline template
trigger:
  branches:
    include: [main, develop]

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Build
  jobs:
  - job: BuildApp
    steps:
    - script: echo "Hello Azure DevOps!"
```

### Common Patterns
- **Multi-environment deployment**: [Stages](./07-stages.md#comprehensive-example)
- **Cross-platform testing**: [Matrix strategies](./10-loops.md#comprehensive-example)
- **Conditional deployment**: [Conditions](./09-conditions.md#comprehensive-example)
- **Custom task development**: [Tasks](./12-tasks.md#custom-task-development)

## 🚀 Getting Started

1. **Choose your learning path** based on your experience level
2. **Follow the lessons in order** for comprehensive understanding
3. **Practice with the examples** in your own Azure DevOps organization
4. **Adapt the patterns** to your specific requirements

## 📋 Prerequisites

- Basic understanding of CI/CD concepts
- Access to Azure DevOps organization
- Familiarity with YAML syntax (covered in [Lesson 01](./01-syntax-structure.md))
- Basic command-line knowledge

## 🤝 Contributing

This training material is designed to be:
- **Practical and actionable**
- **Up-to-date with current Azure DevOps features**
- **Applicable to real-world scenarios**

## 📞 Support

Each lesson includes troubleshooting sections and best practices. For Azure DevOps-specific issues, refer to the [official Microsoft documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/).

---

**Ready to master Azure DevOps pipelines?** Start with [Lesson 01: Syntax & Structure](./01-syntax-structure.md) and build your CI/CD expertise step by step! 🎯