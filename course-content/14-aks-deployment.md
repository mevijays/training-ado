# Module 14 — Deploying to AKS

> **AZ-400 domain:** Define and implement a continuous delivery and release management strategy.

## Why this matters

If your app runs in Kubernetes, "deploy" means updating manifests against a cluster. The exam asks about `kubectl`, Helm, manifests, and AKS specifics.

## Theory

### The Kubernetes object zoo (minimum to know)

| Object | Purpose |
|---|---|
| `Pod` | One or more containers, the smallest unit |
| `Deployment` | Declarative pod management with rolling updates |
| `Service` | Stable network endpoint to a set of pods |
| `Ingress` | HTTP routing into the cluster |
| `ConfigMap` | Non-secret config |
| `Secret` | Sensitive config (base64, not encrypted on its own) |
| `Namespace` | Logical grouping |
| `PersistentVolumeClaim` | Request for storage |
| `Job` / `CronJob` | One-off / scheduled tasks |

### A deployment manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bookstore-api
  labels: { app: bookstore-api }
spec:
  replicas: 3
  selector:
    matchLabels: { app: bookstore-api }
  template:
    metadata:
      labels: { app: bookstore-api }
    spec:
      containers:
        - name: api
          image: acrprod.azurecr.io/bookstore-api:1.2.3
          ports: [{ containerPort: 3000 }]
          env:
            - name: NODE_ENV
              value: production
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          livenessProbe:
            httpGet: { path: /healthz, port: 3000 }
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: bookstore-api
spec:
  selector: { app: bookstore-api }
  ports: [{ port: 80, targetPort: 3000 }]
  type: ClusterIP
```

### Imperative vs declarative

```bash
kubectl create deployment api --image=foo:1   # imperative
kubectl apply -f deploy.yaml                  # declarative — preferred
```

Always commit YAML; never depend on imperative state.

### Helm

A package manager + templating engine for Kubernetes:

```
mychart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml
```

```bash
helm install myapp ./mychart -f values-prod.yaml
helm upgrade myapp ./mychart -f values-prod.yaml
helm rollback myapp 1
```

Templates use Go templating + Sprig functions. Values override per environment.

### Kustomize

Overlay-based alternative — no templating; pure YAML patches.

```
base/
  deploy.yaml
overlays/
  dev/    kustomization.yaml + patches
  prod/   kustomization.yaml + patches
```

```bash
kubectl apply -k overlays/prod
```

### Deploying from Azure Pipelines

```yaml
- task: KubernetesManifest@1
  inputs:
    action: deploy
    kubernetesServiceConnection: aks-prod-sc
    namespace: bookstore
    manifests: 'k8s/deployment.yaml'
    containers: '$(acrName).azurecr.io/bookstore-api:$(Build.BuildId)'
```

Or with Helm:

```yaml
- task: HelmDeploy@0
  inputs:
    connectionType: 'Azure Resource Manager'
    azureSubscription: 'sc-azure'
    azureResourceGroup: 'rg-aks'
    kubernetesCluster: 'aks-prod'
    command: 'upgrade'
    chartType: 'FilePath'
    chartPath: 'charts/bookstore'
    releaseName: 'bookstore'
    valueFile: 'charts/bookstore/values-prod.yaml'
```

### Authentication to AKS from pipelines

| Method | Use |
|---|---|
| **Kubernetes service connection** with AKS | Easy; uses Entra ID under the hood |
| **Azure RM service connection** + `az aks get-credentials` | Most flexible |
| **OIDC federation** (recommended) | No long-lived secrets |
| **Workload identity** for in-cluster jobs | Pods themselves get Azure identity |

### Progressive delivery

For real canary/blue-green in K8s:

- **Argo Rollouts** — replaces Deployment with Rollout CRD that does canary/blue-green natively.
- **Flagger** — same idea, integrates with Istio/Linkerd.
- **AKS Automated Deployments** + **Open Service Mesh** — Microsoft's path.

### GitOps

`kubectl apply` in pipelines is "push" CD. **GitOps** flips it: a controller in the cluster watches a Git repo and reconciles.

Tools: **Argo CD**, **Flux**. Microsoft-managed: **Azure GitOps (Flux)** via the `microsoft.flux` extension.

Benefits:
- Git is the source of truth.
- Cluster pulls; you don't push.
- Drift gets reconciled automatically.

### Analogy

- Kubernetes = a hotel manager.
- Deployment = "always keep 3 rooms occupied by this kind of guest."
- Service = the room phone number — always reaches the right guest, even if they switch rooms.
- Helm = a hotel's seasonal package deals (chart with values).
- Kustomize = "the same suite, but with extra blankets for the winter package."
- GitOps = the manager checks their printed instructions each morning and reorganizes rooms to match.

## Lab — Deploy bookstore-api to AKS via a pipeline

**Goal:** end-to-end pipeline that builds an image and deploys to AKS.

1. Reuse / create an AKS cluster (small B-series):
   ```bash
   az group create -n rg-aks-cd -l eastus
   az aks create -g rg-aks-cd -n aks-cd \
     --node-count 1 --node-vm-size Standard_B2s \
     --generate-ssh-keys --enable-managed-identity \
     --attach-acr <your-acr-name>
   az aks get-credentials -g rg-aks-cd -n aks-cd
   ```
2. Add `k8s/deployment.yaml` and `k8s/service.yaml` to the bookstore repo (from Module 11). Use the manifests above.
3. Add to the pipeline (`azure-pipelines.yml`):
   ```yaml
   - stage: Deploy
     dependsOn: Build
     jobs:
       - deployment: deploy
         environment: aks-prod
         strategy:
           runOnce:
             deploy:
               steps:
                 - task: KubernetesManifest@1
                   inputs:
                     action: deploy
                     kubernetesServiceConnection: 'aks-cd-sc'
                     namespace: 'bookstore'
                     manifests: |
                       k8s/deployment.yaml
                       k8s/service.yaml
                     containers: '$(acrName).azurecr.io/bookstore-api:$(Build.BuildId)'
   ```
4. Create a Kubernetes service connection in AzDO pointing at `aks-cd`.
5. Run the pipeline. Watch:
   ```bash
   kubectl get deploy -n bookstore -w
   kubectl get svc -n bookstore
   ```
6. Test a rolling update by pushing a code change.
7. Try a rollback:
   ```bash
   kubectl rollout history deployment/bookstore-api -n bookstore
   kubectl rollout undo deployment/bookstore-api -n bookstore
   ```
8. Convert to a Helm chart (optional stretch): `helm create bookstore` and migrate manifests.
9. Clean up: `az group delete -n rg-aks-cd --yes`.

## Trainer notes

- Show `kubectl get events --sort-by=.lastTimestamp -A` when a pod won't start — fastest debugging tool.
- Discussion: "Helm vs Kustomize?" — Helm wins on community charts; Kustomize wins on simplicity.
- Common exam trap: `ImagePullBackOff` is fixed by attaching ACR to AKS (`az aks update --attach-acr`), not by adding kube secrets.

## Next

➡ [Module 15 — IaC with Pipelines](15-iac-with-pipelines.md)
⬅ [Module 13 — CD and Deployment Strategies](13-cd-deployment-strategies.md)
