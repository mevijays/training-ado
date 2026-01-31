## We can run step inside docker container.
If we do not have commands or environment available on host agent then use a docker container .
**Example**
```yaml
trigger: 
 - main

pool:
  vmImage: ubuntu-latest

# Define the container here. 
# All steps in this job will execute inside this container.
container: maven:3.9.6-eclipse-temurin-17

parameters:
  - name: relVersion
    type: string
    default: '1.0.0-SNAPSHOT'
    
steps:
- checkout: self

# OPTIONAL: Verify you are in the container
- script: cat /etc/os-release
  displayName: 'Check Container OS'

- task: Maven@4
  inputs:
    mavenPomFile: 'pom.xml'
    goals: 'clean deploy'
    # The container already has Maven/Java, so we just set options
    options: "-s .mvn/settings.xml -Dproject.version=${{ parameters.relVersion }}"
    publishJUnitResults: false
    # These options below are less relevant inside a container 
    # as it uses the container's environment, but keeping them doesn't hurt.
    javaHomeOption: 'JDKVersion' 
    jdkVersionOption: '1.17'
    mavenVersionOption: 'Default'
    mavenAuthenticateFeed: false
    effectivePomSkip: false
    sonarQubeRunAnalysis: false
  env:
    # Environment variables are passed into the container automatically
    PAT: $(System.AccessToken)


```
