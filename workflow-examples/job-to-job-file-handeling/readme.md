Here is a complete, multi-job Azure Pipeline that handles the full workflow: building the Java JAR, passing it between jobs, and then building/pushing the Docker image.

### Key Concepts for Multi-Job Pipelines

1. **Artifact Passing:** Jobs run on different fresh virtual machines. You cannot just use a file path from Job 1 in Job 2. You must **Publish** the JAR in Job 1 and **Download** it in Job 2.
2. **Service Connection:** For a private registry like `git.mevijay.dev`, you need to create a Service Connection in Azure DevOps so the pipeline has permission to push.

---

### Step 1: Create the Service Connection

Before running this, you must tell Azure DevOps how to log in to your registry.

1. Go to **Project Settings** -> **Service connections**.
2. Click **New service connection** -> **Docker Registry**.
3. Choose **Others** (since it is not Docker Hub or ACR).
4. **Docker Registry URL:** `https://git.mevijay.dev`
5. **Docker ID / Password:** Your credentials for that registry.
6. **Service connection name:** `MyCustomRegistry` (Use this exact name in the YAML).

---

### Step 2: The Complete `azure-pipelines.yml`

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  # Shared variables
  imageName: 'git.mevijay.dev/my-app'
  # Just a tag for the docker image (e.g. 1.0.0-buildId)
  dockerTag: '$(Build.BuildId)'

stages:
- stage: BuildAndPush
  jobs:
  
  # =========================================================
  # JOB 1: Maven Build
  # =========================================================
  - job: MavenBuild
    displayName: 'Build JAR'
    steps:
    - checkout: self

    # 1. Build the JAR
    - task: Maven@4
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'clean package' # 'package' creates the JAR in /target
        options: '-s .mvn/settings.xml -DskipTests' # Skip tests for speed in example
        mavenAuthenticateFeed: false
      env:
        PAT: $(System.AccessToken)

    # 2. Publish the JAR as an Artifact
    # This uploads the 'target' folder so Job 2 can access it
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(System.DefaultWorkingDirectory)/target'
        artifact: 'maven-drop'
        publishLocation: 'pipeline'
      displayName: 'Publish JAR Artifact'

  # =========================================================
  # JOB 2: Docker Build & Push
  # =========================================================
  - job: DockerPush
    displayName: 'Build & Push Docker'
    dependsOn: MavenBuild # wait for Job 1 to finish
    condition: succeeded() # run only if Job 1 passed
    steps:
    
    # 1. Download the JAR from Job 1
    - task: DownloadPipelineArtifact@2
      inputs:
        buildType: 'current'
        artifactName: 'maven-drop'
        targetPath: '$(System.DefaultWorkingDirectory)/downloaded-target'
      displayName: 'Download JAR Artifact'

    # Debug step: Show where the file is (Optional)
    - script: ls -R $(System.DefaultWorkingDirectory)/downloaded-target
      displayName: 'Verify JAR Download'

    # 2. Build and Push to Custom Registry
    - task: Docker@2
      inputs:
        containerRegistry: 'MyCustomRegistry' # Name from Step 1
        repository: 'my-app-repo' # The name of the repo inside your registry
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        # Crucial: pass the build context so Docker can find the JAR
        buildContext: '$(System.DefaultWorkingDirectory)' 
        tags: |
          $(dockerTag)
          latest

```

---

### Step 3: The `Dockerfile` Adjustments

Since we are downloading the artifact into a specific folder (`downloaded-target`) in the second job, your `Dockerfile` needs to know where to find the JAR.

Typically, in a single machine build, you might copy from `target/*.jar`. In this multi-job setup, the path slightly changes because we downloaded the artifact to `downloaded-target`.

**Option A: Standard Dockerfile (Best Practice)**
If your `Dockerfile` sits in the root of your repo, update the `COPY` command to look for the JAR where we downloaded it.

```dockerfile
FROM eclipse-temurin:17-jre
WORKDIR /app

# Note the path: 'downloaded-target' is where we put the artifact in Job 2
COPY downloaded-target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]

```

**Option B: Copy command in Pipeline**
If you don't want to change your `Dockerfile`, you can add a script step in Job 2 *before* the Docker task to move the jar to the standard `target/` location:

```yaml
- script: |
    mkdir target
    cp $(System.DefaultWorkingDirectory)/downloaded-target/*.jar target/
  displayName: 'Restore JAR to standard path'

```
