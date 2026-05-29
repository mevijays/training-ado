# Module 7 — Build Tools: Maven, npm, NuGet

> **AZ-400 domain:** Define and implement continuous integration.

## Why this matters

A CI pipeline is mostly **invoking the right build tool with the right arguments**. The exam expects familiarity with the major ecosystems and their package files.

## Theory

### What a build does

Compile (if needed) → run static checks → run tests → produce a **build artifact** (jar, npm tarball, NuGet pkg, Docker image, etc.) → publish it.

Build outputs become **inputs to deployment**.

### Maven (Java)

The classic JVM build tool. Uses **`pom.xml`** (Project Object Model).

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>my-app</artifactId>
  <version>1.0.0</version>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
      <version>3.2.0</version>
    </dependency>
  </dependencies>
</project>
```

Common commands:

```bash
mvn clean             # remove target/
mvn compile           # compile sources
mvn test              # run tests
mvn package           # produce jar/war
mvn install           # install to local repo
mvn deploy            # publish to remote repo
mvn versions:set -DnewVersion=1.0.1
```

Settings file `~/.m2/settings.xml` holds credentials for private repos.

### Gradle (alternative to Maven)

Groovy or Kotlin DSL. More flexible, less ceremony than Maven. Same lifecycle (`build`, `test`, `publish`).

### npm and yarn (JavaScript/TypeScript)

Manifest: **`package.json`**.

```json
{
  "name": "bookstore-api",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc -p .",
    "test": "jest",
    "start": "node dist/index.js"
  },
  "dependencies": { "express": "^4.21.0" }
}
```

Lockfile: `package-lock.json` (npm) or `yarn.lock` (yarn). **Commit it.**

Common commands:

```bash
npm install                  # install per lockfile
npm ci                       # clean install — what CI should use
npm run build
npm test
npm publish                  # publish package
npm version patch            # bump 1.0.0 → 1.0.1
```

### NuGet (.NET)

Manifest: `*.csproj` (modern) or `packages.config` (legacy).

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
  </ItemGroup>
</Project>
```

Common commands:

```bash
dotnet restore
dotnet build
dotnet test
dotnet publish -c Release
dotnet nuget push *.nupkg --source <feed>
```

### Python

Manifests: `pyproject.toml` (modern), `setup.py` (older), `requirements.txt` (frozen).

Tools:
- `pip` — package installer.
- `poetry` / `uv` — modern dependency managers.

```bash
pip install -r requirements.txt
pytest
python -m build
twine upload dist/*
```

### Go

```bash
go mod init github.com/me/app
go build ./...
go test ./...
```

Modules are versioned via `go.mod` + git tags (`v1.2.3`).

### Artifact repositories

Where built packages go:

| Tool | Public registry | Private options |
|---|---|---|
| Maven | Maven Central | Azure Artifacts, JFrog Artifactory, Nexus, GitHub Packages |
| npm | npmjs.com | Azure Artifacts, GitHub Packages, Verdaccio |
| NuGet | nuget.org | Azure Artifacts, GitHub Packages, Nexus |
| Python | PyPI | Azure Artifacts, GitHub Packages, devpi |
| Docker | Docker Hub | ACR, GHCR, Quay |

**Azure Artifacts** (Module 16) handles all of the above in one feed.

### Analogy

- Build tool = a chef who turns raw ingredients (source code) into a finished dish (artifact).
- Lockfile = the chef's exact recipe — same dish every time.
- Artifact repo = the freezer where finished dishes wait to be served (deployed).

## Lab — Build three things, three ways

**Goal:** invoke each major build tool once.

1. **Maven — Spring Boot app**:
   ```bash
   curl https://start.spring.io/starter.zip -o demo.zip \
     -d type=maven-project -d language=java -d bootVersion=3.2.0 \
     -d baseDir=demo-mvn -d dependencies=web && unzip demo.zip
   cd demo-mvn
   mvn clean package
   ls target/*.jar
   ```
2. **npm — TypeScript**:
   ```bash
   mkdir demo-ts && cd demo-ts
   npm init -y
   npm i -D typescript jest @types/jest ts-jest
   npx tsc --init
   echo 'console.log("hi")' > index.ts
   npm pkg set scripts.build="tsc" scripts.test="jest"
   npm run build && node index.js
   ```
3. **NuGet / .NET — Web API**:
   ```bash
   mkdir demo-net && cd demo-net
   dotnet new webapi
   dotnet build
   dotnet test || true
   dotnet publish -c Release -o out
   ```
4. (Optional) **Python** and **Go** following the same pattern.
5. Note the **artifact paths** in each: `target/*.jar`, `dist/`, `out/`, `dist/*.tar.gz`, the Go binary. These become pipeline inputs in Module 8.

## Trainer notes

- Show one of the build files in detail (`pom.xml` or `package.json`) — students often haven't *read* them.
- Discussion: "Why use `npm ci` instead of `npm install` in CI?" — strict lockfile, no mutations, fail-fast.
- Common confusion: NuGet *packages* vs NuGet *feeds*. Packages are the artifacts; feeds are the registries.

## Next

➡ [Module 8 — Azure Pipelines CI Basics](08-azure-pipelines-ci.md)
⬅ [Module 6 — Azure Repos](06-azure-repos.md)
