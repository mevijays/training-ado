# Azure DevOps Pipeline Examples

This folder contains all the example YAML pipelines used in training.

## Contents

| File | Description |
|------|-------------|
| [simple-without-stage.yaml](./simple-without-stage.yaml) | Basic pipeline without stages |
| [multi-steps.yaml](./multi-steps.yaml) | Multiple steps in a single job |
| [multijob.yaml](./multijob.yaml) | Multiple jobs example |
| [multi-job-with-depends-on.yaml](./multi-job-with-depends-on.yaml) | Job dependencies with dependsOn |
| [multi-stage.yaml](./multi-stage.yaml) | Multi-stage pipeline |
| [structure.yaml](./structure.yaml) | Complete pipeline structure reference |
| [conditions-demo.yaml](./conditions-demo.yaml) | All condition types demo (eq, ne, and, or, etc.) |
| [on-pr-run.yaml](./on-pr-run.yaml) | PR trigger pipeline |
| [approval-deployment-demo.yaml](./approval-deployment-demo.yaml) | Environment approvals & deployments |
| [schedule-trigger.yaml](./schedule-trigger.yaml) | Scheduled/cron triggers |
| [parameters.yml](./parameters.yml) | Pipeline parameters demo |
| [variable-group.yml](./variable-group.yml) | Variable groups usage |
| [azure-key-vault-variable.yml](./azure-key-vault-variable.yml) | Azure Key Vault integration |
| [secure-file.yaml](./secure-file.yaml) | Secure files usage |
| [self-hosted-pool.yaml](./self-hosted-pool.yaml) | Self-hosted agent pool |

## Subdirectories

| Directory | Description |
|-----------|-------------|
| [artifact/](./artifact/) | Artifact publishing & downloading |
| [build-deploy-webapp/](./build-deploy-webapp/) | Web app build & deploy example |
| [helm-deploy/](./helm-deploy/) | Helm chart deployment |
| [terraform/](./terraform/) | Terraform pipelines |
| [job-to-job-file-handeling/](./job-to-job-file-handeling/) | File sharing between jobs |
| [jobs-in-container/](./jobs-in-container/) | Running jobs in containers |
| [steps-inside-container/](./steps-inside-container/) | Container steps example |
