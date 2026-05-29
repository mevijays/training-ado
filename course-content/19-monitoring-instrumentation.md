# Module 19 — Monitoring and Instrumentation

> **AZ-400 domain:** Develop an instrumentation strategy (5-10%).

## Why this matters

You can deploy faster than ever; if you can't *see* what's happening, you'll deploy bugs faster than ever. Monitoring is the feedback loop that closes DevOps.

## Theory

### The three pillars of observability

| Pillar | Question it answers |
|---|---|
| **Metrics** | What's the rate / latency / error count? |
| **Logs** | What happened at 14:32:01? |
| **Traces** | Where did this request spend time, across services? |

A fourth pillar is **events** (business events, audit trail).

### Azure Monitor (recap)

The umbrella that holds:

- **Metrics** — numeric time series.
- **Logs** — Log Analytics workspace; queried with KQL.
- **Application Insights** — APM (Application Performance Monitoring).
- **Alerts** — fire on metric/log conditions.
- **Action groups** — what to do on alert (email, SMS, webhook, Logic App).

### Application Insights

Auto-instruments .NET, Java, Node, Python apps. Tracks:

- **Requests** — rate, duration, status code.
- **Dependencies** — outbound calls to DB, HTTP, queues.
- **Exceptions** — stack traces grouped by signature.
- **Custom metrics and events**.
- **User flows** — page views, sessions, funnels.

### Distributed tracing

OpenTelemetry is the open standard. Modern App Insights SDKs are OTel-compatible.

A trace = a tree of spans across services:

```
trace_id: abc123
└── HTTP GET /search       (web-frontend, 80ms)
    └── HTTP GET /api/books (api, 60ms)
        └── postgres query (db, 30ms)
```

Click a slow trace; see exactly where time went.

### Logging best practices

- **Structured logs** (JSON), not concatenated strings.
- Include `correlation_id` or `trace_id` in every log line.
- Don't log secrets.
- Log levels: ERROR / WARN / INFO / DEBUG / TRACE. Default to INFO in prod.
- Log slow requests, failed requests, business events; not every line of code.

### Dashboards

Three layers worth keeping:

1. **Executive** — high-level uptime, conversion rate.
2. **Service** — per-service SLOs, error budget.
3. **Engineer** — debug-level metrics during incidents.

### Alerts

Aim for **actionable** alerts. The on-call rule:

- An alert that doesn't lead to a clear action = noise. Delete it.
- Page on **symptoms**, not causes. ("p95 latency > 500ms" beats "CPU > 80%".)
- Page only what's worth waking someone for; everything else → ticket.

### Pipeline-relevant instrumentation tasks

What the AZ-400 exam likes:

- Adding App Insights to a pipeline via the **ApplicationInsights** task.
- Annotating App Insights with **release markers**:
  ```yaml
  - task: ApplicationInsightsAnnotation@1
    inputs:
      applicationInsightsResourceId: '/subscriptions/.../microsoft.insights/components/ai-prod'
      releaseName: 'Bookstore $(Build.BuildId)'
  ```
- **Querying** App Insights as a pipeline gate (fail deploy if error rate spikes).
- Producing **deployment markers** so dashboards correlate deploys to anomalies.

### DORA metrics (recap)

- Deploy frequency
- Lead time
- Change failure rate
- MTTR

You can pull all four from Azure DevOps + App Insights:

| Metric | Source |
|---|---|
| Deploy frequency | Pipeline runs to prod environment |
| Lead time | Time from commit to prod deploy |
| Change failure rate | % of deploys that triggered a rollback or incident |
| MTTR | Avg time from alert to resolution |

### Analogy

- Metrics = a car's dashboard (constantly updated, glanceable).
- Logs = the on-board diagnostic computer's stored events.
- Traces = the GPS route, showing where the car was at each moment.
- Alerts = the dashboard warning lights.
- Dashboards = a fleet manager's TV showing all the cars at once.

## Lab — Instrument and dashboard the bookstore-api

**Goal:** add App Insights, fire a test alert, mark a deploy.

1. Create App Insights:
   ```bash
   RG=rg-instr-lab
   az group create -n $RG -l eastus
   az monitor log-analytics workspace create -g $RG -n law-app -l eastus
   WORKSPACE_ID=$(az monitor log-analytics workspace show -g $RG -n law-app --query id -o tsv)
   az monitor app-insights component create -a ai-bookstore -g $RG -l eastus \
     --workspace $WORKSPACE_ID --application-type web
   ```
2. Get the connection string:
   ```bash
   CS=$(az monitor app-insights component show -g $RG -a ai-bookstore --query connectionString -o tsv)
   echo $CS
   ```
3. Add SDK to the Node app:
   ```bash
   npm i applicationinsights
   ```
   At the top of `index.js`:
   ```js
   const appInsights = require('applicationinsights');
   appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING).start();
   ```
4. Set the env var in App Service:
   ```bash
   az webapp config appsettings set -g $RG -n <your-webapp> \
     --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$CS"
   ```
5. Generate some traffic. After a few min, query in **App Insights → Logs**:
   ```kusto
   requests
   | summarize count() by bin(timestamp, 1m), resultCode
   | render timechart
   ```
6. **Alert**: failure rate > 5% for 5 min → email you.
   ```bash
   az monitor metrics alert create -g $RG -n alert-failures \
     --scopes $(az monitor app-insights component show -g $RG -a ai-bookstore --query id -o tsv) \
     --condition "avg requests/failed > 5 percentage" \
     --description "Failure rate too high"
   ```
7. Add **release annotations** to a pipeline (so deploy markers appear in dashboards):
   ```yaml
   - task: ApplicationInsightsAnnotation@1
     inputs:
       connectedServiceNameARM: 'sc-azure'
       applicationInsightsResourceId: '/subscriptions/<sub>/resourceGroups/$(RG)/providers/microsoft.insights/components/ai-bookstore'
       releaseName: '$(Build.BuildNumber)'
   ```
8. Build a **dashboard** with: requests/sec, failure rate, p95 latency, top exceptions, dependency map.
9. Clean up: `az group delete -n $RG --yes`.

## Trainer notes

- Show the App Insights **Application Map** — students see the dep graph for the first time.
- Discussion: "What's a good first alert to set up?" — uptime check + high error rate. Skip CPU alerts at first.
- Common exam trap: App Insights workspace-based vs classic — workspace-based is the modern, recommended mode (uses LA underneath).

## Next

➡ [Module 20 — SRE Strategy](20-sre-strategy.md)
⬅ [Module 18 — Secrets and Azure Key Vault](18-secrets-keyvault.md)
