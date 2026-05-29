# Module 3 — Agile Planning with Azure Boards

> **AZ-400 domain:** Design and implement processes and communications.

## Why this matters

The exam asks scenario questions about Scrum vs Kanban, work item hierarchy, and how to model real workflows. It's process-heavy.

## Theory

### Agile in 60 seconds

A way of working that values:
- Working software over comprehensive documentation
- Customer collaboration over contract negotiation
- Responding to change over following a plan
- Individuals and interactions over processes and tools

### Scrum vs Kanban

| | Scrum | Kanban |
|---|---|---|
| Cadence | Fixed-length sprints (1-4 weeks) | Continuous flow |
| Commitment | Whole sprint at once | One item at a time |
| Roles | PO, SM, Devs | Flexible |
| Meetings | Planning, daily, review, retro | Daily standup |
| Metric | Velocity (story points/sprint) | Cycle time, throughput |
| Change mid-cycle | Discouraged | Allowed |
| Good when | Predictable feature work | Ops, support, mixed workloads |

Many teams blend them ("Scrumban").

### Work item hierarchy (Agile template)

```
Epic
└── Feature
    └── User Story
        └── Task
        └── Bug
```

- **Epic** = quarterly goal ("Add multi-region support").
- **Feature** = monthly outcome ("EU region live").
- **Story** = sprint-sized user value ("As an EU user, I want pricing in EUR").
- **Task** = a day's work ("Update currency lookup table").
- **Bug** = something broken.

### Backlog and sprint

- **Backlog** = ordered list of all unfinished work.
- **Sprint** = a time-boxed slice you commit to.
- **Velocity** = story points completed per sprint.
- **Capacity** = team-hours available.

### Kanban board

Columns represent states (New / Active / Resolved / Closed by default). Set **WIP limits** to enforce "stop starting, start finishing."

### Queries and dashboards

- **Queries** — saved filters across work items (e.g., "all bugs assigned to me, sev 1").
- **Dashboards** — pinnable widgets: burndown, build status, cycle time, lead time.
- **Analytics** — OData feed for Power BI.

### Notifications

Per user/team subscriptions. Examples: "notify me when a work item I created changes" or "notify the team channel when build fails."

### Integrations

- **GitHub** — link commits, PRs, issues to AzDO work items via `AB#123`.
- **Microsoft Teams** — work item updates as Teams messages.
- **Outlook** — email-to-work-item.
- **Slack** — webhook-based.

### Estimation techniques

- **Story points** — Fibonacci (1, 2, 3, 5, 8, 13). Relative size.
- **T-shirt sizes** — XS/S/M/L/XL.
- **Effort hours** — concrete; doesn't scale to long-term planning.
- **#NoEstimates** — count items, ignore size.

### Analogy

- **Epic** = "build the house."
- **Feature** = "build the kitchen."
- **User Story** = "install the sink."
- **Task** = "buy the faucet."
- **Sprint** = a one-week working block.
- **Kanban board** = the contractor's whiteboard of which rooms are framed / drywalled / painted.

## Lab — Run a mini-sprint

**Goal:** model a small feature end-to-end in Azure Boards.

1. In the `bookstore` project (from Module 2), go to **Boards**.
2. Create an Epic: **"Search functionality"**.
3. Add a Feature: **"Full-text search across titles and authors"**.
4. Add three Stories:
   - "As a customer I want to search by title"
   - "As a customer I want to search by author"
   - "As an admin I want to see most-searched terms"
5. Add tasks under each story (3-5 each).
6. **Start a sprint**: Backlog → New Sprint → pick a 1-week window.
7. Drag stories into the sprint until you've committed reasonable scope.
8. Open the **Sprint board** (Boards → Sprints → Taskboard).
9. Move a task through New → Active → Resolved → Done.
10. Create a query: "All bugs created in last 7 days assigned to me."
11. Create a dashboard with three widgets: Sprint burndown, Build status (will be empty for now), Cycle time.
12. Set up GitHub integration: link a GitHub repo and confirm a commit message like `Fix #42 AB#5` cross-links.

## Trainer notes

- Most students new to Boards underestimate the hierarchy. Walk through the default Agile process flow.
- Discussion: "When does WIP-limiting matter?" — when context-switching is killing throughput.
- Common exam trap: the **process template** is set at project creation and very hard to change after.

## Next

➡ [Module 4 — Git Version Control](04-git-version-control.md)
⬅ [Module 2 — Azure DevOps Overview](02-azure-devops-overview.md)
