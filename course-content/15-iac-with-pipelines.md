# Module 15 — IaC with Pipelines

> **AZ-400 domain:** Define and implement a continuous delivery and release management strategy.

## Why this matters

If your *app* is deployed via pipelines but your *infra* is provisioned by hand, you have two sources of truth. IaC + pipelines closes the loop.

## Theory

### The pattern

```
infra repo  →  CI: plan      →  CD: apply on merge
                ↓
            posts plan as PR comment
```

Same pattern for Terraform, Bicep, and ARM:
1. PR triggers `plan` / `what-if`.
2. Reviewers see the diff in the PR.
3. Merge triggers `apply` / `deploy` to the target environment.
4. State / deployment history is centralized.

### Terraform in Azure Pipelines

```yaml
trigger: [main]

pool: { vmImage: ubuntu-latest }

variables:
  TF_IN_AUTOMATION: 'true'

stages:
  - stage: Plan
    jobs:
      - job: plan
        steps:
          - task: AzureCLI@2
            displayName: 'terraform plan'
            inputs:
              azureSubscription: 'sc-azure'
              addSpnToEnvironment: true
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                export ARM_CLIENT_ID=$servicePrincipalId
                export ARM_OIDC_TOKEN=$idToken
                export ARM_TENANT_ID=$tenantId
                export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
                export ARM_USE_OIDC=true

                terraform init -backend-config=key=prod.tfstate
                terraform plan -out=tfplan
          - publish: tfplan
            artifact: tfplan

  - stage: Apply
    dependsOn: Plan
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    jobs:
      - deployment: apply
        environment: prod
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: tfplan
                - task: AzureCLI@2
                  inputs:
                    azureSubscription: 'sc-azure'
                    addSpnToEnvironment: true
                    scriptType: bash
                    scriptLocation: inlineScript
                    inlineScript: |
                      # ... same env vars ...
                      terraform init -backend-config=key=prod.tfstate
                      terraform apply tfplan
```

Key points:

- **OIDC federated identity** instead of secrets.
- `plan` is published as an artifact; `apply` consumes the **exact** saved plan.
- Apply only runs after merge to `main` and gated by environment approval.

### Bicep in Azure Pipelines

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'sc-azure'
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az deployment group what-if \
        -g rg-bookstore-prod \
        -f infra/main.bicep \
        -p @infra/prod.parameters.json

- task: AzureCLI@2
  inputs:
    azureSubscription: 'sc-azure'
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az deployment group create \
        -g rg-bookstore-prod \
        -f infra/main.bicep \
        -p @infra/prod.parameters.json
```

`what-if` is the Bicep equivalent of `terraform plan` — shows the diff before applying.

### State / deployment history

| Tool | Stores history in |
|---|---|
| **Terraform** | Backend (Azure Storage, S3, HCP Terraform) |
| **Bicep / ARM** | Azure deployment history (per RG/sub) |
| **Pulumi** | Pulumi Cloud or self-hosted backend |

### OIDC federation for pipelines → Azure

The modern, secret-less auth flow:

1. Create a User-Assigned Managed Identity or App Registration in Entra ID.
2. Add a federated credential trust on it, scoped to the AzDO service connection.
3. AzDO pipeline gets an OIDC token from AzDO, exchanges with Entra for an Azure access token.
4. No client secrets stored anywhere.

In Azure DevOps: **Service connection → "Workload identity federation (automatic)"** sets this up for you.

### Cost guardrails

| Tool | Use |
|---|---|
| **infracost** | Estimates Terraform plan cost; comments on PR |
| **Azure Cost Management budgets** | Alerts when subscription overspends |
| **Tagging policy** | Required tags drive cost allocation |

### Drift detection

- **HCP Terraform** (paid) — periodic drift checks.
- **Custom**: scheduled pipeline that runs `terraform plan -refresh-only` and fails if drift exists.
- **Bicep**: no native drift — re-run deployments to converge.

### Analogy

- IaC in CI/CD = automated quality control on the assembly line that produces your infrastructure.
- Plan = QC inspection (no changes yet).
- Apply = stamping the part with the QC seal and putting it into the world.

## Lab — Terraform via Azure Pipelines with OIDC

**Goal:** wire up a real Terraform pipeline using OIDC, with plan-on-PR and apply-on-merge.

1. Create a backend storage account (one-time bootstrap, by hand):
   ```bash
   az group create -n rg-tfstate -l eastus
   az storage account create -n tfstate$RANDOM -g rg-tfstate -l eastus --sku Standard_LRS
   SA=$(az storage account list -g rg-tfstate --query "[0].name" -o tsv)
   az storage container create --account-name $SA -n tfstate --auth-mode login
   echo "SA=$SA"
   ```
2. In Azure DevOps: **Project Settings → Service connections → New → Azure Resource Manager → Workload Identity Federation (automatic)**. Name it `sc-azure`.
3. Add `infra/main.tf`:
   ```hcl
   terraform {
     backend "azurerm" {}
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-iac-cd-demo"
     location = "eastus"
     tags     = { managed_by = "azure-pipelines" }
   }
   ```
4. Add `infra/azure-pipelines-tf.yml` based on the YAML in the Theory section. Reference your backend storage account name and container.
5. Open a PR; observe `plan` runs and posts results.
6. Merge — `apply` runs, blocked by environment approval. Approve → RG created.
7. Make a small change (add a tag), PR, plan, merge, apply.
8. Try a destroy job (optional): a separate pipeline that runs `terraform destroy` against the same state.

## Trainer notes

- Show **what-if** output for Bicep — students compare it favorably with `terraform plan`.
- Discussion: "Should infra and app live in the same repo?" — depends on lifecycle. Often: yes, for app-specific infra; no, for shared platform infra.
- Common exam trap: storing the Terraform state in a public storage account = catastrophic. Use private endpoints + RBAC.

## Next

➡ [Module 16 — Azure Artifacts](16-azure-artifacts.md)
⬅ [Module 14 — Deploying to AKS](14-aks-deployment.md)
