# Module 20 — SRE Strategy

> **AZ-400 domain:** Develop a Site Reliability Engineering strategy (5-10%).

## Why this matters

SRE is Google's discipline for keeping production reliable while shipping fast. AZ-400 added a dedicated domain in 2026 — expect SLI/SLO/SLA/error-budget questions.

## Theory

### What SRE is

A way of running ops that applies software engineering to operations:

- **Treat ops as a software problem.**
- **Set explicit reliability targets** (SLOs).
- **Budget errors** rather than chasing 100% uptime.
- **Reduce toil** by automating repetitive work.
- **Blameless incident reviews.**

### SLI, SLO, SLA

| Term | Definition | Example |
|---|---|---|
| **SLI** (Service Level Indicator) | A measurable property | "Fraction of HTTP 200 responses to /search" |
| **SLO** (Service Level Objective) | Internal target on an SLI | "99.9% of /search requests return 200 in any 30-day window" |
| **SLA** (Service Level Agreement) | External contractual promise | "99.5% uptime or we refund 10%" |

Rule of thumb: SLO is stricter than SLA. SLI is the raw measurement.

### Error budget

If your SLO is 99.9%, your **error budget** is 0.1% — about 43 minutes of downtime per month.

- Plenty of budget left? Ship features faster, take more risk.
- Budget exhausted? Stop shipping; focus on reliability.

This makes reliability a **team conversation, not a CTO mandate**.

### Choosing SLOs

- Pick SLIs that **directly reflect user experience** (request success, request latency, freshness of data).
- Set the target **just high enough** to satisfy users — not 100%.
- Measure over a meaningful **window** (rolling 28-day is common).
- Have **few** SLOs per service. 2-4 max.

### Toil

Toil = manual, repetitive ops work that scales with growth.

Examples:
- Manually restarting a flaky service every week.
- Manually granting access on each ticket.
- Manually copying logs around.

SRE practice: cap toil at ~50% of the team's time; reduce the rest via automation.

### Incident management

A standard playbook:

1. **Detect** — alert fires.
2. **Mitigate** — restore service quickly (rollback, scale up, traffic shift).
3. **Communicate** — status page, customer comms.
4. **Resolve** — root cause fixed.
5. **Learn** — blameless postmortem.

Microsoft offers **Azure Resource Health**, **Service Health**, and **Azure Status** for upstream incidents.

### Blameless postmortems

Focus on **systems**, not individuals. Questions:

- What happened (timeline)?
- What was the impact?
- What were the contributing factors?
- What would we change in the system to prevent recurrence?
- Action items, with owners and dates.

Anti-pattern: "X engineer broke prod" — never. Even if X pushed the button, the *system* let them.

### On-call

- **Rotation** — fair distribution; never solo.
- **Pages must be actionable** (Module 19).
- **Postmortems for every page** (or at least every Sev-1/2).
- **Compensate** for on-call hours (extra pay or time off).
- **Handoff** — clear runbooks; status doc each rotation.

### Chaos engineering

Deliberately inject failures to test resilience:

- Kill random pods.
- Latency injection.
- DB failover drills.
- Region failover tests.

Tools: **Azure Chaos Studio**, Chaos Mesh, Litmus, Gremlin.

### Capacity planning

Forecast: traffic growth, seasonal spikes, marketing-driven peaks. Set:
- Autoscaling rules.
- Reserved capacity (Reserved Instances).
- Headroom (e.g., 30% above peak).
- Quota requests to Azure ahead of needs.

### DORA metrics in SRE

DORA's "Accelerate" book + the State of DevOps report align with SRE practice. SRE adds:
- **Reliability** as a fifth DORA metric in 2024+ reports.
- Explicit SLO/error budget framing.

### Analogy

- **SLO** = the speed limit you self-impose on a road trip — not the legal max (SLA), and not your speedometer (SLI).
- **Error budget** = the gas tank — drive at the speed limit, you use it linearly; speed = use faster; brakes = save fuel.
- **Toil** = doing the same chores every day; SRE = the contractor who installs the dishwasher so you stop hand-washing.

## Lab — Define an SLO + error budget burn-rate alert

**Goal:** turn abstract SRE concepts into a real KQL alert.

1. Decide your SLO: "99% of /search requests succeed (HTTP 2xx) in the last 30 days."
2. SLI in KQL (App Insights):
   ```kusto
   let window = 30d;
   requests
   | where timestamp > ago(window)
   | where url contains "/search"
   | summarize total = count(), failed = countif(success == false)
   | extend successRate = 1.0 - (failed * 1.0 / total)
   ```
3. **Burn-rate alert** — fast-burn means you'll exhaust the month's error budget in 1 hour:
   ```kusto
   let slo = 0.99;
   let window = 1h;
   requests
   | where timestamp > ago(window)
   | where url contains "/search"
   | summarize total = count(), failed = countif(success == false)
   | extend rate = failed * 1.0 / total
   | extend burn = rate / (1.0 - slo)
   | where burn > 14.4   // 14.4x = 1-hr burn-rate threshold
   ```
4. Create a log alert with this query, evaluated every 5 min over the last hour. Action group: page on-call.
5. Repeat for slow-burn (e.g., 3 / 6h windows) to catch slower drifts.
6. Document the SLO, SLI, and burn-rate rules in `docs/slo.md` in the repo.
7. Add a dashboard tile showing **error budget remaining this month**.

## Trainer notes

- Show how setting an SLO at 99.99% on a small team produces zero error budget — the team panics. Lower SLOs are not failure.
- Discussion: "Should every service have an SLO?" — yes, even if the target is generous. Without one, reliability conversations are unfounded.
- Common exam trap: SLA ≠ SLO. The SLA is what you owe customers; the SLO is what you commit to internally.

## Next

➡ [Module 21 — GitHub Actions](21-github-actions.md)
⬅ [Module 19 — Monitoring and Instrumentation](19-monitoring-instrumentation.md)
