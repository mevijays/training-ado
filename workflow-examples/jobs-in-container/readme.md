## jobs in container
we can run one job in one container or pool and another job in another container or pool. this is helpful in case you know that the tools whihc reuires for your steps may not be available on agent then better to use an image.

```yaml
trigger:
- main

# 1. Define the runner pool globally (same runner type for both)
pool:
  vmImage: 'ubuntu-latest'

variables:
  imageName: 'git.mevijay.dev/my-app'
  dockerTag: '$(Build.BuildId)'

stages:
- stage: BuildAndPush
  jobs:
  
  # =========================================================
  # JOB 1: Maven Build -> Uses a JAVA container
  # =========================================================
  - job: MavenBuild
    displayName: 'Build JAR (Java Container)'
    
    # Specific container for this job
    container: maven:3.9.6-eclipse-temurin-17
    
    steps:
    - checkout: self

    - task: Maven@4
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'clean package'
        options: '-s .mvn/settings.xml -DskipTests'
        mavenAuthenticateFeed: false
      env:
        PAT: $(System.AccessToken)

    # Publish the JAR so Job 2 can see it
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(System.DefaultWorkingDirectory)/target'
        artifact: 'maven-drop'
        publishLocation: 'pipeline'

  # =========================================================
  # JOB 2: Docker Build -> Uses a DOCKER container
  # =========================================================
  - job: DockerPush
    displayName: 'Build Image (Docker Container)'
    dependsOn: MavenBuild
    condition: succeeded()
    
    # Specific container for this job
    container: 
      image: docker:stable # A lightweight image with docker CLI installed
      # CRITICAL: Map the host's Docker socket so this container can spawn sibling containers
      options: -v /var/run/docker.sock:/var/run/docker.sock

    steps:
    - checkout: self
    
    # Download the JAR from Job 1
    - task: DownloadPipelineArtifact@2
      inputs:
        buildType: 'current'
        artifactName: 'maven-drop'
        targetPath: '$(System.DefaultWorkingDirectory)/downloaded-target'

    # Build and Push
    - task: Docker@2
      inputs:
        containerRegistry: 'MyCustomRegistry'
        repository: 'my-app-repo'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        # Point build context to where we downloaded the artifact
        buildContext: '$(System.DefaultWorkingDirectory)'
        tags: |
          $(dockerTag)
          latest
```
