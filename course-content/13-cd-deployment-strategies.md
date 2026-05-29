# Module 13 — CD and Deployment Strategies

> **AZ-400 domain:** Define and implement a continuous delivery and release management strategy.

## Why this matters

Knowing how to deploy without taking the site down is a senior-engineer skill. The exam asks scenario questions: which strategy fits which constraint?

## Theory

### CI vs CD

| | Continuous Integration | Continuous Delivery | Continuous Deployment |
|---|---|---|---|
| Goal | Code merges + tests | Every change is **deployable** | Every change is **deployed** |
| Human | None | Manual approval to ship | None |
| Frequency | Per commit | Per commit, ship on demand | Per commit, ship automatically |

Most regulated industries do CD (continuous *delivery*); SaaS teams do continuous *deployment*.

### Deployment strategies

#### 1. Recreate

Stop the old, start the new. Downtime.

```
v1 ────🛑
            v2 ──────►
```

Only ok if downtime is acceptable.

#### 2. Rolling

Update instances N at a time. Brief mixed-version state.

```
[v1 v1 v1 v1]
[v2 v1 v1 v1]
[v2 v2 v1 v1]
[v2 v2 v2 v1]
[v2 v2 v2 v2]
```

Default for Kubernetes Deployments.

#### 3. Blue/Green

Two complete environments. Switch traffic atomically. Roll back by switching back.

```
green (live)  ◀──── traffic
blue (idle)   ▼ deploy v2, smoke test
                    
SWAP
                    
blue (live) ◀──── traffic
green (idle)
```

Doubles infra cost briefly; instant rollback.

In Azure: **App Service deployment slots** are blue/green by design.

#### 4. Canary

Send a small % of traffic to v2; ramp up if healthy.

```
[v1 v1 v1 v1 v1 v1 v1 v1 v1 v2]   10%
[v1 v1 v1 v1 v1 v1 v2 v2 v2 v2]   40%
[v2 v2 v2 v2 v2 v2 v2 v2 v2 v2]  100%
```

Combine with feature flags + automatic rollback if error rate spikes.

#### 5. Ring deployment (Microsoft term)

Concentric rings: ring 0 = internal dogfood, ring 1 = small customer subset, ring 2 = beta, ring 3 = all. Move v2 outward, observing.

#### 6. A/B testing

Two versions live to compare metrics. Not a release strategy; an experiment.

#### 7. Shadow / dark launch

Mirror traffic to v2 but don't return its responses. Test prod traffic against new code.

### Decision table

| Constraint | Strategy |
|---|---|
| Downtime acceptable, cheap | Recreate |
| Default for K8s | Rolling |
| Need instant rollback | Blue/Green |
| Want progressive traffic | Canary |
| Multi-ring customer base | Ring |
| Comparing features statistically | A/B |
| Stress-test prod with safety | Shadow |

### Release gates and approvals

In Azure Pipelines **environments**, you add **checks** before a deploy proceeds:

| Check | Purpose |
|---|---|
| **Manual approval** | Human must click |
| **Branch control** | Only deploy from `main` (or release branches) |
| **Business hours** | Only deploy 9-5 weekdays |
| **Required template** | Pipeline must extend the org template |
| **Invoke REST API** | Custom gate (e.g., ServiceNow ticket open) |
| **Query Azure Monitor** | KQL must return < N errors |
| **Evaluate artifact** | Image must have no critical CVEs |

Stack as many as needed.

### Rollback patterns

| Pattern | How |
|---|---|
| Slot swap back | App Service: swap blue ↔ green |
| Kubernetes rollback | `kubectl rollout undo deployment/myapp` |
| Re-deploy old image | Just trigger pipeline with old tag |
| Feature flag off | Decouple deploy from release |
| Database rollback | Hardest — design migrations to be forward-compatible |

### Forward-compatible DB migrations (expand/contract)

```
v1 reads + writes col A
                ↓
v2 reads col A or B, writes both    ← deploy app v2
                ↓
v3 reads + writes col B             ← deploy app v3, drop col A later
```

Never break old code with a destructive migration. Always do an expand → migrate data → contract sequence over multiple releases.

### Analogy

- **Recreate** = move out, then move in. House empty for a day.
- **Rolling** = swap furniture one room at a time.
- **Blue/Green** = furnished apartment next door is ready; just walk over.
- **Canary** = let one friend stay overnight first to see if everything works.
- **Ring** = invite family this week, friends next, public after that.

## Lab — Blue/Green with App Service slots

**Goal:** demonstrate a real blue/green deploy with rollback.

1. Setup:
   ```bash
   RG=rg-bg-lab
   PLAN=plan-bg
   APP=appbg$RANDOM
   az group create -n $RG -l eastus
   az appservice plan create -g $RG -n $PLAN --sku S1 --is-linux
   az webapp create -g $RG -p $PLAN -n $APP --runtime "NODE:20-lts"
   ```
2. Deploy v1 to production slot:
   ```bash
   mkdir v1 && cd v1
   echo "{\"version\":\"1.0\"}" > package.json
   cat > server.js <<'EOF'
   const http = require('http');
   http.createServer((_,r)=>r.end('v1.0 hello')).listen(process.env.PORT||8080);
   EOF
   zip -r ../v1.zip .
   cd ..
   az webapp deployment source config-zip -g $RG -n $APP --src v1.zip
   curl https://$APP.azurewebsites.net
   ```
3. Create staging slot:
   ```bash
   az webapp deployment slot create -g $RG -n $APP --slot staging
   ```
4. Deploy v2 to **staging**:
   ```bash
   mkdir v2 && cd v2
   cp ../v1/package.json .
   cat > server.js <<'EOF'
   const http = require('http');
   http.createServer((_,r)=>r.end('v2.0 hello')).listen(process.env.PORT||8080);
   EOF
   zip -r ../v2.zip .
   cd ..
   az webapp deployment source config-zip -g $RG -n $APP --src v2.zip --slot staging
   curl https://$APP-staging.azurewebsites.net
   ```
5. Swap staging → production:
   ```bash
   az webapp deployment slot swap -g $RG -n $APP --slot staging --target-slot production
   curl https://$APP.azurewebsites.net    # now v2
   curl https://$APP-staging.azurewebsites.net    # now v1
   ```
6. **Roll back** with another swap:
   ```bash
   az webapp deployment slot swap -g $RG -n $APP --slot staging --target-slot production
   curl https://$APP.azurewebsites.net    # back to v1
   ```
7. Clean up: `az group delete -n $RG --yes`.

## Trainer notes

- Show **Slot settings** that can be marked "Sticky" (don't swap) — e.g., environment-specific config.
- Discussion: "Where do canary deployments fit in Azure?" — Application Gateway / Front Door weighted routes, App Service traffic routing rules, AKS with Istio/Argo Rollouts.
- Common exam trap: deployment slot swaps are metadata-only (no compute change), so they're nearly instant.

## Next

➡ [Module 14 — Deploying to AKS](14-aks-deployment.md)
⬅ [Module 12 — Container Registries (ACR)](12-container-registries.md)
