# Azure DevOps Pipeline YAML Syntax Structure

## Overview
Azure DevOps Pipelines use YAML (Yet Another Markup Language) to define continuous integration and continuous deployment workflows. Understanding the syntax structure is fundamental to creating effective pipelines.

## Explanation
YAML syntax in Azure Pipelines follows a hierarchical structure with specific keywords that define different aspects of your CI/CD process. The basic building blocks include:

- **Pipeline**: The root-level container for your entire workflow
- **Triggers**: Define when the pipeline should run
- **Pool**: Specifies which agent will execute the pipeline
- **Variables**: Store reusable values
- **Stages**: High-level logical boundaries in your pipeline
- **Jobs**: Collection of steps that run sequentially on the same agent
- **Steps**: Individual tasks or commands to execute

## Analogy
Think of an Azure Pipeline YAML file like a recipe for cooking a complex meal:

- The **recipe name** is your pipeline name
- **When to cook** (triggers) - like "cook this every Sunday" or "when guests arrive"
- **Kitchen setup** (pool/agent) - which kitchen and equipment you'll use
- **Ingredients list** (variables) - reusable components you'll need
- **Cooking phases** (stages) - prep, cooking, plating, serving
- **Individual cooking tasks** (jobs) - chopping vegetables, cooking meat, making sauce
- **Specific instructions** (steps) - "chop onions for 2 minutes", "heat oil to 350°F"

Just like a recipe has a specific order and structure, YAML pipelines have a defined hierarchy that must be followed.

## Key Syntax Elements

### 1. Indentation
- Uses 2 spaces for indentation (no tabs)
- Proper indentation is crucial for YAML parsing

### 2. Key-Value Pairs
```yaml
key: value
```

### 3. Lists
```yaml
items:
  - item1
  - item2
  - item3
```

### 4. Multi-line Strings
```yaml
script: |
  echo "Line 1"
  echo "Line 2"
```

## Example Workflow YAML

```yaml
# Pipeline name
name: 'Basic Pipeline Structure Example'

# Trigger configuration
trigger:
  branches:
    include:
      - main
      - develop

# Agent pool specification
pool:
  vmImage: 'ubuntu-latest'

# Variables definition
variables:
  buildConfiguration: 'Release'
  projectName: 'MyApplication'

# Pipeline stages
stages:
  - stage: 'Build'
    displayName: 'Build Stage'
    jobs:
      - job: 'BuildJob'
        displayName: 'Build Application'
        steps:
          - checkout: self
            displayName: 'Checkout source code'
          
          - task: UseDotNet@2
            displayName: 'Setup .NET SDK'
            inputs:
              packageType: 'sdk'
              version: '6.x'
          
          - script: |
              echo "Building $(projectName) in $(buildConfiguration) mode"
              dotnet build --configuration $(buildConfiguration)
            displayName: 'Build application'
          
          - script: |
              echo "Running unit tests"
              dotnet test --configuration $(buildConfiguration) --no-build
            displayName: 'Run tests'

  - stage: 'Deploy'
    displayName: 'Deploy Stage'
    dependsOn: 'Build'
    condition: succeeded()
    jobs:
      - job: 'DeployJob'
        displayName: 'Deploy Application'
        steps:
          - script: |
              echo "Deploying $(projectName) to production"
              echo "Deployment completed successfully"
            displayName: 'Deploy to production'
```

## Best Practices

1. **Use meaningful names**: Choose descriptive names for stages, jobs, and steps
2. **Consistent indentation**: Always use 2 spaces for indentation
3. **Comments**: Use `#` to add comments explaining complex logic
4. **Display names**: Add `displayName` properties for better readability in the UI
5. **Organize logically**: Group related steps within jobs and jobs within stages
6. **Use variables**: Store reusable values as variables to avoid duplication

## Common YAML Syntax Rules

- Strings with special characters should be quoted
- Boolean values: `true`, `false`
- Numbers don't need quotes
- Lists start with `-` followed by a space
- Objects use key-value pairs with `:` separator
- Multi-line strings use `|` or `>` indicators

## Validation Tips

- Use VS Code with Azure Pipelines extension for syntax validation
- Test your YAML structure before committing
- Check indentation carefully - incorrect indentation is the most common error
- Validate expressions and variable references

This foundational understanding of YAML syntax structure will enable you to create more complex and powerful Azure DevOps pipelines.
