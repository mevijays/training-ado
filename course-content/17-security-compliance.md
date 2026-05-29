# Module 17 — Security and Compliance

> **AZ-400 domain:** Develop a security and compliance plan (10-15%).

## Why this matters

"Shift-left security" is now table stakes. The exam tests SAST, DAST, SCA, secret scanning, and supply chain controls — and which to apply where in the pipeline.

## Theory

### The security-in-pipeline cheat sheet

| Stage | Check | Tools |
|---|---|---|
| PR open | Secret scanning | GitHub Advanced Security (GHAS), gitleaks |
| PR open | SAST (static analysis) | CodeQL, SonarCloud, Semgrep |
| PR open | SCA (vuln deps) | Dependabot, Dependency Track, Snyk, GHAS |
| Build | IaC scan | Checkov, tfsec, Trivy config |
| Build | Container image scan | Trivy, Defender for Containers, Snyk |
| Build | License compliance | FOSSA, Black Duck |
| Pre-deploy | DAST (running app) | OWASP ZAP |
| Runtime | Posture | Defender for Cloud, Sentinel |
| Always | Supply chain provenance | SBOM (CycloneDX, SPDX), Sigstore |

### Acronyms decoded

- **SAST** — Static Application Security Testing. Scans source for patterns (`eval(...)`, SQLi).
- **DAST** — Dynamic. Scans a running app from outside (fuzzing, SQLi probes).
- **SCA** — Software Composition Analysis. Are my dependencies vulnerable?
- **IAST** — Interactive (in-process during tests). Less common.
- **RASP** — Runtime protection (in the app itself).
- **SBOM** — Software Bill of Materials.

### Shift-left vs runtime

| Phase | Cost to fix | Time to detect |
|---|---|---|
| Developer's laptop | $1 | Seconds |
| PR / build | $10 | Minutes |
| Test environment | $100 | Hours |
| Production | $10,000+ | Days/weeks |

The earlier you catch a vuln, the cheaper. Hence "shift left."

### GitHub Advanced Security (GHAS) for Azure DevOps

Microsoft's enterprise add-on, includes:

- **Secret scanning** — blocks pushes with known secret patterns.
- **Code scanning** — CodeQL-based SAST.
- **Dependency scanning** — known vulnerable deps.

Enable per-repo in Repos → Settings.

### Microsoft Defender for DevOps

A SaaS that aggregates security posture across multiple AzDO orgs / GitHub orgs into a single dashboard. Surfaces:
- Secrets in repos
- IaC misconfigurations
- Open vulnerabilities
- Posture across many pipelines

### Supply chain attacks

Real cases the exam may reference (or hint at):

- **event-stream** (npm, 2018) — malicious dependency.
- **SolarWinds** (2020) — compromised build server.
- **Log4Shell** (2021) — vuln in widely-used dep.
- **3CX** (2023) — signed-but-trojaned update.

Defensive practices:

- Pin dependencies (lockfiles, `~>` operators).
- Vendor / cache via Azure Artifacts (Module 16).
- Generate SBOMs and store with artifacts.
- Sign images and artifacts (cosign, Notation).
- Restrict who can publish to feeds.
- Use OIDC, not long-lived secrets.

### Compliance frameworks (high-level)

Frameworks Microsoft tracks against Azure: **ISO 27001, SOC 1/2/3, PCI DSS, HIPAA, GDPR, FedRAMP, NIST 800-53**.

Compliance involves:
- Documented policies.
- Demonstrated controls (often via Azure Policy).
- Audit trails (Activity logs, audit logs).
- Regular review (annual or semi-annual).

### Azure Policy for compliance

(Recap from AZ-104 / Module 5 in that course.) Built-in initiatives map to many frameworks:

```bash
az policy assignment create \
  --name "CIS-Azure-1.4.0" \
  --policy-set-definition "<id-of-CIS-Foundations-1.4.0>" \
  --scope /subscriptions/<sub>
```

### Approvals and gates

Compliance often demands manual approvals for production. Combine:
- Environment approvals (Module 9).
- Branch policies requiring linked work items.
- Pipeline checks (e.g., a Defender for Cloud scan must pass).

### Analogy

- SAST = a spell-checker that reads your code for misspellings (vulnerabilities) before you ship.
- DAST = a stress-tester that pokes the running app from outside.
- SCA = a hygiene check on the food (dependencies) you bring into the kitchen.
- SBOM = the ingredient list on the packaging — required for some regulators.
- Defender = a security camera + alarm across your whole property.

## Lab — Wire a CodeQL + Trivy + secret-scan pipeline

**Goal:** add three security gates to the bookstore pipeline.

1. **Secret scanning**: enable GHAS for the repo (if licensed) OR use `gitleaks`:
   ```yaml
   - task: Bash@3
     inputs:
       targetType: inline
       script: |
         docker run --rm -v $(pwd):/repo zricethezav/gitleaks:latest detect --source=/repo -v
   ```
2. **SAST with CodeQL**:
   ```yaml
   - task: AdvancedSecurity-Codeql-Init@1
     inputs:
       languages: 'javascript'
   - script: npm ci && npm run build
   - task: AdvancedSecurity-Codeql-Analyze@1
   ```
   (Requires GHAS for AzDO.)
3. **Image scan with Trivy**:
   ```yaml
   - script: |
       docker build -t bookstore-api:$(Build.BuildId) .
       docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
         aquasec/trivy:latest image --severity HIGH,CRITICAL \
         --exit-code 1 bookstore-api:$(Build.BuildId)
   ```
4. **IaC scan with Checkov** (if you have Terraform/Bicep):
   ```yaml
   - script: pip install checkov && checkov -d infra/ --soft-fail
   ```
5. **SBOM** with syft:
   ```yaml
   - script: |
       curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
       syft bookstore-api:$(Build.BuildId) -o cyclonedx-json > sbom.json
   - publish: sbom.json
     artifact: sbom
   ```
6. Run the pipeline; verify each gate behaves correctly. Introduce a known-vulnerable dep (`lodash@4.17.4`) to confirm SCA catches it.

## Trainer notes

- Show one real CVE and walk it from `npm audit` → fix → re-scan → green.
- Discussion: "Why fail builds on HIGH but not MEDIUM CVEs?" — pragmatism + noise vs. signal.
- Common exam trap: secret scanning catches *patterns*; long random API keys that don't match a known pattern still slip through — defense in depth required.

## Next

➡ [Module 18 — Secrets and Azure Key Vault](18-secrets-keyvault.md)
⬅ [Module 16 — Azure Artifacts](16-azure-artifacts.md)
