# Module 12 — Container Registries (ACR)

> **AZ-400 domain:** Define and implement continuous integration.

## Why this matters

Where you store images matters for security, geo-latency, and supply chain. The exam asks about ACR features and integration patterns.

## Theory

### What a registry is

A server that stores Docker (and OCI) images. Public examples: Docker Hub, Quay.io, GHCR. Private: Azure Container Registry (ACR), Amazon ECR, Google Artifact Registry, JFrog Artifactory.

### Azure Container Registry (ACR)

Microsoft's private registry. Three tiers:

| Tier | Storage | Features |
|---|---|---|
| **Basic** | 10 GB | Dev/test. Single region. |
| **Standard** | 100 GB | Most production. |
| **Premium** | 500 GB | Geo-replication, content trust, private endpoints, token-based auth, repository-scoped permissions. |

### Authentication

| Method | Use |
|---|---|
| **Entra ID + RBAC** (recommended) | `az acr login` uses your Entra session |
| **Admin user** | Quick start; password-based; disable for prod |
| **Service Principal** | For CI integrations without OIDC |
| **Tokens** (Premium) | Scoped to specific repos, time-limited |
| **AKS managed identity** | Pull-only, no kubeconfig changes needed |

### Roles

| Role | Permissions |
|---|---|
| `AcrPull` | Pull images |
| `AcrPush` | Pull + push |
| `AcrDelete` | Delete images |
| `Contributor` | Manage the ACR resource |

Assign `AcrPull` to your AKS cluster's identity for seamless pulling.

### Geo-replication

Premium tier replicates images to multiple regions. A `docker pull acr.azurecr.io/img:tag` from a VM in West Europe hits the closest replica.

### Content trust + signed images

Use Notary v2 (cosign / Notation) to sign images. Verify at deploy.

### ACR Tasks

Build and patch images in ACR without a pipeline runner:

- **Quick task** — one-off: `az acr build -t myimage:1.0 -r myacr .`.
- **Triggered task** — on commit / on base image update / on schedule.

Base-image-update tasks are great for auto-patching: when `node:20-alpine` updates, your derivative image rebuilds.

### Vulnerability scanning

- **Microsoft Defender for Containers** scans pushed images for CVEs.
- **Trivy / Snyk / Grype** as pipeline steps.

### Image lifecycle

Retention policy (Premium): "delete untagged manifests older than 30 days" / "keep last N tags."

### Push from a pipeline (the right way)

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'sc-azure'   # OIDC service connection
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az acr login -n $(acrName)
      docker build -t $(acrName).azurecr.io/bookstore-api:$(Build.BuildId) .
      docker push $(acrName).azurecr.io/bookstore-api:$(Build.BuildId)
```

Or the Docker task:

```yaml
- task: Docker@2
  inputs:
    containerRegistry: 'acr-sc'     # service connection
    repository: 'bookstore-api'
    command: 'buildAndPush'
    Dockerfile: '**/Dockerfile'
    tags: |
      $(Build.BuildId)
      latest
```

### Pulling from AKS (no secrets)

```bash
az aks update -n aks-prod -g rg-aks --attach-acr $(az acr show -n acrprod --query id -o tsv)
```

This gives the AKS kubelet identity `AcrPull` on the registry. Deployments just reference `acrprod.azurecr.io/myimage:tag` — no `imagePullSecret`.

### Analogy

- Registry = the freezer warehouse where boxed meals (images) live.
- Replication = warehouses in many cities, same inventory.
- ACR Tasks = a kitchen attached to the warehouse, so you don't have to truck the ingredients home to assemble.

## Lab — Geo-replicated ACR with auto-build

**Goal:** push an image, replicate, and set up an auto-rebuild on base image update.

1. Create a Premium ACR with replication:
   ```bash
   RG=rg-acr-prem
   ACR=acrprem$RANDOM
   az group create -n $RG -l eastus
   az acr create -g $RG -n $ACR --sku Premium
   az acr replication create -r $ACR --location westeurope
   ```
2. Login:
   ```bash
   az acr login -n $ACR
   ```
3. Use **ACR Tasks** to build remotely (no local Docker needed):
   ```bash
   mkdir bookstore-img && cd bookstore-img
   cat > Dockerfile <<'EOF'
   FROM node:20-alpine
   CMD ["node", "-e", "console.log('hi')"]
   EOF
   az acr build -t bookstore-api:1.0 -r $ACR .
   ```
4. List repositories and check replication status:
   ```bash
   az acr repository list -n $ACR -o table
   az acr replication list -r $ACR -o table
   ```
5. Create a **base-image-update task**:
   ```bash
   az acr task create -r $ACR -n nightly-rebuild \
     --image bookstore-api:autobuild \
     --context . --file Dockerfile \
     --commit-trigger-enabled false \
     --base-image-trigger-enabled true
   ```
6. Test pull from another region (in theory):
   ```bash
   docker pull $ACR.azurecr.io/bookstore-api:1.0
   ```
7. Attach to an AKS cluster (if you have one running from Module 14):
   ```bash
   az aks update -n <cluster> -g <rg> --attach-acr $ACR
   ```
8. Clean up: `az group delete -n $RG --yes`.

## Trainer notes

- Show **Microsoft Defender for Containers** vulnerability scan results — students see the value immediately.
- Discussion: "Why not Docker Hub?" — rate limits, no private VNet, no Entra ID integration for orgs.
- Common exam trap: ACR's "Admin user" is convenient but its single shared password is a security gap. Disable in prod.

## Next

➡ [Module 13 — CD and Deployment Strategies](13-cd-deployment-strategies.md)
⬅ [Module 11 — Docker and Containers](11-docker-containers.md)
