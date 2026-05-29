# Module 22 — Feature Flags

> **AZ-400 domain:** Cross-cutting — appears in process, CI/CD, and SRE domains.

## Why this matters

Feature flags **decouple deploy from release**. You can ship code dark, then flip it on for 1% of users. The exam asks scenario questions about progressive rollout.

## Theory

### What a feature flag is

A boolean (or richer) toggle that gates code paths:

```js
if (await featureFlags.isEnabled('newSearch', { userId })) {
  return useNewSearch(query);
}
return useOldSearch(query);
```

The flag's value lives **outside the code** (in a flag service / config store), so you can change behavior without redeploying.

### Why teams use flags

1. **Decouple deploy from release** — merge to main without exposing the feature.
2. **Progressive rollout** — 1% → 10% → 50% → 100% with a kill switch.
3. **A/B testing** — measure the impact of a feature on real users.
4. **User-segment targeting** — only beta users see the new UI.
5. **Operational kill switches** — disable a slow query under load.
6. **Environment-specific config** — different flag values for dev/stage/prod.

### Types of flags

| Type | Lifetime | Examples |
|---|---|---|
| **Release flag** | Days/weeks; remove after launch | Showing a new feature to all users |
| **Experiment flag** | Days/weeks; remove after experiment | A/B test of two checkout flows |
| **Ops / kill switch** | Long-lived | Disable expensive endpoint under load |
| **Permission flag** | Long-lived | Premium-tier features |

Important: **delete release/experiment flags after they're done.** Old flags = dead code.

### Azure App Configuration with Feature Manager

Microsoft's managed flag service. Two pieces:

1. **Azure App Configuration** — a resource that stores key-value pairs (and feature flags).
2. **Microsoft.FeatureManagement** SDK — lets your code consume flags by name.

```bash
az appconfig create -g rg-config -n appconfigbookstore -l eastus --sku free
az appconfig feature set -n appconfigbookstore --feature newSearch --description "New search UI"
```

In .NET:

```csharp
builder.Configuration.AddAzureAppConfiguration(opts =>
    opts.Connect(connectionString)
        .UseFeatureFlags());

builder.Services.AddFeatureManagement();
```

```csharp
if (await _featureManager.IsEnabledAsync("newSearch"))
{
    return NewSearch();
}
```

In Node, use [`@azure/app-configuration`](https://www.npmjs.com/package/@azure/app-configuration) or fetch flags via REST.

### Targeting filters

App Configuration supports filters:

- **Targeting** — % of users, named users, groups.
- **Time window** — flag on between dates.
- **Custom** — write your own filter.

### Third-party services

- **LaunchDarkly** — the leader; rich targeting + experimentation.
- **Statsig**, **Split.io**, **GrowthBook**, **Unleash** — alternatives.

For most Azure-only teams, Azure App Configuration is enough.

### Flag-driven progressive rollout pattern

```
1. Merge feature behind a flag set to off.            ← release branch is clean
2. Deploy to prod (no user-visible change).            ← deploy decoupled from release
3. Turn flag on for internal team users.               ← dogfood
4. Turn flag on for 1% of customer traffic.            ← canary
5. Watch error rate, latency, business metrics.        ← Module 19
6. Ramp 10% → 50% → 100% over days.
7. Once stable, remove the flag from code.             ← cleanup
```

### Dangers

- **Flag debt** — old flags pile up.
- **Default-on bugs** — what happens if the flag service is unreachable? Always have a sane default.
- **Combinatorial explosion** — many flags multiplied = untested combinations.
- **Privacy** — targeting by user ID can leak who's experimenting on what.

### Pipeline integration

| Pattern | How |
|---|---|
| Toggle a flag from a pipeline | `az appconfig feature set ... --no-prompt --enabled true` |
| Block deploy if flag is on (gate) | Pipeline check that queries the service |
| Auto-disable flag on alert | Action group → Logic App → flag service API |

### Analogy

- Feature flag = a light switch wired in the *building*, not the lamp itself.
- You ship the lamp dark (with bulb installed). When ready, flick the switch from the lobby.
- Progressive rollout = a dimmer slider, not on/off.
- A kill switch = the master breaker for emergencies.

## Lab — Build a progressive rollout with Azure App Configuration

**Goal:** put a feature flag in front of a code path and roll it out by percentage.

1. Create App Configuration:
   ```bash
   RG=rg-flags-lab
   az group create -n $RG -l eastus
   az appconfig create -g $RG -n appcfg$RANDOM -l eastus --sku free
   CFG=$(az appconfig list -g $RG --query "[0].name" -o tsv)
   ```
2. Create a feature flag:
   ```bash
   az appconfig feature set -n $CFG --feature newSearch --description "New search UI"
   az appconfig feature show -n $CFG --feature newSearch
   ```
3. Add a percentage filter (50% of users):
   ```bash
   az appconfig feature filter add -n $CFG --feature newSearch \
     --filter-name Microsoft.Percentage \
     --filter-parameters "Value=50"
   ```
4. Toggle on/off:
   ```bash
   az appconfig feature enable -n $CFG --feature newSearch
   az appconfig feature disable -n $CFG --feature newSearch
   ```
5. Integrate into a tiny Node demo:
   ```bash
   npm i @azure/app-configuration @azure/identity
   ```
   ```js
   const { AppConfigurationClient } = require('@azure/app-configuration');
   const { DefaultAzureCredential } = require('@azure/identity');
   const client = new AppConfigurationClient(
     `https://${process.env.CFG}.azconfig.io`,
     new DefaultAzureCredential()
   );
   async function isEnabled(name) {
     const f = await client.getConfigurationSetting({ key: `.appconfig.featureflag/${name}` });
     return JSON.parse(f.value).enabled;
   }
   isEnabled('newSearch').then(v => console.log('newSearch on?', v));
   ```
6. Toggle the flag with `az appconfig feature enable / disable` and re-run.
7. Pipeline gate idea — fail deploy if flag is on during a freeze:
   ```yaml
   - script: |
       on=$(az appconfig feature show -n $(cfg) --feature deploy-freeze --query state -o tsv)
       if [ "$on" = "on" ]; then echo "Deploys frozen"; exit 1; fi
   ```
8. Clean up: `az group delete -n $RG --yes`.

## Trainer notes

- Show that flag changes propagate immediately (with SDK push refresh) or with a refresh interval (poll mode).
- Discussion: "When to remove a flag?" — when it's been at 100% for 2+ weeks with no incidents.
- Common exam trap: feature flags **inside Azure App Configuration** are a specific subset of settings (different key prefix). Easy to confuse with regular settings.

## Next

➡ [Exam Preparation](exam-prep.md)
⬅ [Module 21 — GitHub Actions](21-github-actions.md)
