# Module 18 — Secrets and Azure Key Vault

> **AZ-400 domain:** Develop a security and compliance plan.

## Why this matters

Where pipeline secrets live decides whether you ever leak them. The exam has multiple scenario questions about pipeline secret patterns.

## Theory

### The hierarchy of secret hygiene (worst → best)

1. ❌ Hardcoded in YAML.
2. ❌ Pipeline variable, set as plain.
3. ⚠️ Pipeline variable, marked **secret**.
4. ⚠️ **Variable group** with secret variables.
5. ✅ **Variable group linked to Azure Key Vault** (secrets live in KV).
6. ✅ **OIDC federation** to Azure — no secrets at all.
7. ✅ **Managed identity in self-hosted agent** — agent fetches secrets at runtime.

Aim for the top three.

### Pipeline variables and secrets

Mark a variable as secret in the UI. Secrets:
- Are masked in logs (best-effort; complex outputs may slip through).
- Are not exposed as env vars to scripts unless you map them explicitly:

```yaml
- script: echo $MYVAR > /dev/null     # won't show value
  env:
    MYVAR: $(my-secret)
```

- Are not propagated to child processes by default.
- Stay within the pipeline run (not shared across pipelines).

### Variable groups

A **variable group** is a named bag of variables managed in **Library**. Usable across pipelines in a project.

```yaml
variables:
  - group: bookstore-prod-vars
  - name: localVar
    value: hi
```

Variable groups can be **linked to Azure Key Vault** so that:
- Secrets live in KV (single source of truth).
- Pipeline reads at job time using a service connection.
- Rotation: change in KV, no pipeline change needed.

To link:
1. Library → + Variable group → Link to Azure Key Vault.
2. Pick the service connection + KV name.
3. Choose which secrets to expose.

### Azure Key Vault basics

(Recap from AZ-104.) Key Vault holds:
- **Secrets** — opaque strings.
- **Keys** — RSA/EC, often for encryption.
- **Certificates** — TLS certs, with auto-renewal.

Access control:
- **RBAC mode** (newer, preferred) — Azure RBAC roles like `Key Vault Secrets User`.
- **Access policy mode** (legacy) — KV-specific ACL.

### OIDC for pipeline → cloud

The gold standard. No client secret stored in AzDO. Use **Workload Identity Federation** when creating an Azure Resource Manager service connection.

### Secure Files

Binary file secrets (kubeconfig, .pfx, JSON key files):

```yaml
- task: DownloadSecureFile@1
  name: kubeconfig
  inputs:
    secureFile: prod-kubeconfig
- script: kubectl --kubeconfig=$(kubeconfig.secureFilePath) get nodes
```

### Secret rotation patterns

| Pattern | Strategy |
|---|---|
| **Periodic** | Cron rotates monthly. KV auto-generates new versions. |
| **On compromise** | Manual rotation; revoke old immediately. |
| **Short-lived tokens** | Tokens valid minutes; pipeline mints fresh each run. |

### Federated identity for GitHub Actions → Azure

Equivalent to AzDO's OIDC. Created via:
```bash
az ad app create --display-name "github-actions-bookstore"
# add federated credential constrained to specific repo + branch
```

### What NOT to do (real war stories)

- ❌ Commit `.env` to a public repo (rotate everything if you did).
- ❌ Pass secrets as task `inputs:` — they end up in logs.
- ❌ Set a variable group to "Allow all pipelines" — anyone can read it.
- ❌ Use the KV admin role for the pipeline SP — overscoped.

### Analogy

- Pipeline variable secret = a sealed envelope on the office desk. Easy. Anyone in the office could open it.
- Key Vault = a safe with controlled access logs.
- KV-linked variable group = the safe sends you a one-time code each time you need it.
- OIDC = you wear a verified employee badge — the cloud trusts you without holding your password.

## Lab — Three ways to handle a DB password

**Goal:** evolve a pipeline through three approaches to handling secrets.

1. **Bad approach** — pipeline variable in YAML:
   ```yaml
   variables:
     dbPassword: 'P@ssw0rd!'   # never do this
   ```
   Commit this and notice the bad smell.
2. **OK approach** — pipeline UI secret variable:
   - Pipelines → Variables → add `dbPassword`, mark secret.
   - Remove the bad version.
3. **Better** — Key Vault linked variable group:
   ```bash
   az group create -n rg-secrets-pipeline -l eastus
   az keyvault create -n kvbook$RANDOM -g rg-secrets-pipeline -l eastus
   KV=$(az keyvault list -g rg-secrets-pipeline --query "[0].name" -o tsv)
   az keyvault secret set --vault-name $KV --name db-password --value "$(openssl rand -base64 32)"
   ```
   - In AzDO: **Library → + Variable group → bookstore-prod-vars → Link Azure Key Vault → pick $KV → check `db-password`**.
   - Grant the service connection's identity `Key Vault Secrets User` on the vault.
   - Pipeline:
     ```yaml
     variables:
       - group: bookstore-prod-vars
     steps:
       - script: |
           echo "Using DB password (masked)"
           # In a real script you'd use $(db-password) for DB auth
         env:
           DB_PASS: $(db-password)
     ```
4. **Best (no secret at all)** — OIDC to Azure:
   - Service connection already uses workload identity federation.
   - Don't store any DB password at rest — generate per-deploy from a script that uses managed identity to access KV.
5. Rotate the secret in KV; observe the pipeline picks it up automatically on next run.
6. Clean up: `az group delete -n rg-secrets-pipeline --yes`.

## Trainer notes

- Show **System.AccessToken** in a script. It's a powerful default-scoped token; if exposed in logs, it's bad.
- Discussion: "Why is KV-linked variable group better than just KV API calls in scripts?" — declarative; one place to audit; rotation is invisible to pipelines.
- Common exam trap: secret variables on the pipeline level are NOT propagated to scripts unless mapped via `env:`.

## Next

➡ [Module 19 — Monitoring and Instrumentation](19-monitoring-instrumentation.md)
⬅ [Module 17 — Security and Compliance](17-security-compliance.md)
