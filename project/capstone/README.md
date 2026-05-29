# BlueLeaf Bookstore — AZ-400 Capstone Reference Solution

A **working reference solution** for the [BlueLeaf CI/CD capstone](../README.md). Use it to compare against your own attempt, or as a starting point.

> ⚠️ Teaching solution. Pipelines target Azure Pipelines as primary, with a GitHub Actions variant for the frontend. SKUs and limits are tuned for free-tier learning.

## Structure

```
capstone/
├── templates/                ← shared pipeline templates
│   ├── steps-build-node.yml
│   ├── steps-build-java.yml
│   ├── steps-build-python.yml
│   ├── steps-docker-build-push.yml
│   ├── steps-security-scan.yml
│   └── stages-deploy.yml
├── pipelines/                ← per-service pipeline YAML
│   ├── bookstore-api.yml     ← Java/Maven
│   ├── bookstore-web.yml     ← Node/React
│   ├── bookstore-worker.yml  ← Python
│   └── bookstore-infra.yml   ← Bicep plan/apply
├── services/                 ← minimal sample code per service
│   ├── bookstore-api/
│   ├── bookstore-web/
│   └── bookstore-worker/
├── infra/                    ← Bicep for the deploy targets
│   └── main.bicep
├── k8s/                      ← Kubernetes manifests for api + worker
│   ├── api.yaml
│   └── worker.yaml
└── github-actions/           ← GitHub Actions equivalent for the frontend
    └── ci-cd-web.yml
```

## How the pieces fit

```
┌──────────────────────┐    ┌──────────────────────┐
│  bookstore-api repo  │   │  bookstore-web repo  │
│  + pipelines/api.yml │   │  + pipelines/web.yml │
└──────────┬───────────┘   └──────────┬───────────┘
           │  uses templates from           │
           │  templates/ (extends-template) │
           ▼                                ▼
       Azure Pipelines runs build → scan → push image → deploy
                              │
                              ▼
                  AKS (api, worker) / App Service (web)
                              │
                              ▼
                       Front Door + WAF
```

## Prerequisites

1. Azure DevOps org + project (per Module 2 of the course).
2. Service connection `sc-azure` of type "Azure Resource Manager — Workload Identity Federation".
3. Azure subscription with rights to create everything in `infra/main.bicep`.
4. ACR named `blueleafacr` (or update the variable).
5. AKS cluster named `aks-blueleaf` attached to the ACR.

One-time bootstrap:

```bash
RG=rg-blueleaf-shared
az group create -n $RG -l eastus
az acr create -g $RG -n blueleafacr --sku Basic
az aks create -g $RG -n aks-blueleaf --node-count 1 --node-vm-size Standard_B2s \
  --enable-managed-identity --attach-acr blueleafacr --generate-ssh-keys
```

## Running the pipelines

1. Push **the whole training-ado repo** to Azure Repos (the pipelines use `project/capstone/...` paths because that's where they live in this teaching repo).
2. In Azure DevOps → Pipelines → New pipeline → Existing YAML → pick `project/capstone/pipelines/bookstore-api.yml`. Repeat for each service.
3. The first run will prompt you to grant the service connection and variable group access.
4. Add a variable group `blueleaf-shared` (Library) with `acrName=blueleafacr`, `aksName=aks-blueleaf`, `rgName=rg-blueleaf-shared`.
5. Create environments `dev` and `prod`. Add a manual approval to `prod`.
6. Create a Kubernetes service connection named `aks-blueleaf-sc` pointing at the AKS cluster.
7. The web pipeline assumes you've already deployed the [Azure capstone](../../../training-azure/project/capstone/) so the App Services exist. (App names include a `uniqueString` suffix; the pipeline looks them up by prefix.)

> **If you extract just the capstone into a new repo:** strip the `project/capstone/` prefix from every `paths.include`, `workingDirectory`, and `manifests` path in the pipeline YAML.

## Mapping to the capstone phases

| Phase | Where |
|---|---|
| 1-3. Boards + Repos + CI | per-service pipelines + branch policies you set up in the UI |
| 4. Self-hosted agent | (optional) point one pipeline at a self-hosted pool |
| 5. Container + ACR | `templates/steps-docker-build-push.yml` |
| 6. IaC | `pipelines/bookstore-infra.yml` + `infra/main.bicep` |
| 7. CD | `templates/stages-deploy.yml` + `k8s/*.yaml` |
| 8. Security | `templates/steps-security-scan.yml` |
| 9. Artifacts | the api pipeline publishes a Maven artifact (commented section) |
| 10. Observability + SRE | App Insights is provisioned in `infra/main.bicep`; alert config is doc'd in the runbook section |
| 11. Feature flags | `templates/steps-feature-flag.yml` (gate on a freeze flag) |
| 12. GitHub Actions variant | `github-actions/ci-cd-web.yml` |

## Where to extend (homework)

- Argo Rollouts / Flagger for canary deploys.
- Chaos Studio experiments.
- GHAS for AzDO secret scanning.
- Cost dashboards via infracost.

## Navigation

- ⬅ [Project description](../README.md)
- ⬅ [Course content](../../course-content/README.md)
- ⬅ [Repo README](../../README.md)
