# Module 10 — Self-hosted Agents

> **AZ-400 domain:** Define and implement continuous integration.

## Why this matters

Microsoft-hosted agents are fine for most public-internet workloads. But the moment you need to reach private resources, use specialized hardware, or run long jobs, you go self-hosted. The exam tests when and how.

## Theory

### Microsoft-hosted vs self-hosted

| | Microsoft-hosted | Self-hosted |
|---|---|---|
| Provisioning | Free or pay-per-parallel | You provision the VM/container |
| Per-job state | Clean every time | Persistent (unless you clean) |
| Software | Pre-installed broad image | Whatever you install |
| Speed | Cold start each time | Hot caches available |
| Network reach | Public internet only | Can reach private VNet, on-prem |
| Cost (large scale) | $40/parallel/month | $15/parallel/month + your VM costs |
| Maintenance | None | OS patches, agent upgrades |

### When to self-host

- Build needs access to a private VNet (DB, internal services).
- Need GPUs, large RAM, ARM, mainframe, etc.
- Long jobs (> 60 min on hosted often gets tight).
- Strict compliance requires data on your network.
- Heavy caching saves significant time.

### Agent flavors

| Flavor | Use |
|---|---|
| **Agent VM** (Linux/Windows/Mac) | Most common |
| **Agent in container** | Ephemeral, fast-start; great with Kubernetes |
| **Scale set agents** | Azure VMSS-backed pool, auto-scales |

### Setting up a Linux agent

```bash
# On a Linux VM
mkdir myagent && cd myagent
curl -O https://vstsagentpackage.azureedge.net/agent/<version>/vsts-agent-linux-x64-<version>.tar.gz
tar xzf vsts-agent-linux-x64-*.tar.gz
./config.sh \
  --url https://dev.azure.com/<org> \
  --auth pat \
  --token <PAT> \
  --pool default \
  --agent my-linux-agent \
  --unattended
sudo ./svc.sh install
sudo ./svc.sh start
```

### Scale Set Agents (Azure VMSS)

The recommended self-hosted setup. Azure DevOps autoscales a VMSS pool based on job demand:

1. Create a VMSS in Azure (Linux/Windows image).
2. Set instances = 0 (idle).
3. Project Settings → Agent pools → Add → Azure virtual machine scale set → point at your VMSS.
4. Configure max agents, idle agents, expiration.

When a job queues, AzDO scales the VMSS up; when idle, it scales down (or destroys instances).

### Container jobs

Run each job inside a container on a hosted/self-hosted agent:

```yaml
pool:
  vmImage: ubuntu-latest

jobs:
  - job: build
    container: node:20
    steps:
      - script: node --version
```

Or step-level:

```yaml
- script: ...
  target:
    container: my-build-image
```

Use cases:
- Pin exact toolchain versions.
- Run on a hardened base image.
- Build for a specific Linux distro.

### Demands and capabilities

Agents publish **capabilities** (OS, installed tools). Jobs specify **demands**:

```yaml
pool:
  name: my-pool
  demands:
    - agent.os -equals Linux
    - mvn
```

### Authentication: PAT vs OAuth vs Managed Identity

Modern self-hosted agents support:

- **PAT** (Personal Access Token) — easy, rotates manually.
- **Service Principal + OAuth** — better for CI bootstrap.
- **Managed Identity** (Azure VMs) — best for Azure-hosted agents.

### Updating agents

Agents auto-update by default. To pin a version, set `--disableupdate` or manage manually.

### Agent security model

Agents have access to:
- The pipeline's workspace (cloned repo).
- The `System.AccessToken` for the duration of the job (callable as `$(System.AccessToken)`).
- Any secrets the pipeline exposes.

Self-hosted agent **does not** get implicit access to Azure resources; it uses the same service connections.

### Analogy

- **Microsoft-hosted agent** = renting an Uber. Clean car each time, you pay per trip.
- **Self-hosted agent** = your company van. Always available, but you maintain it.
- **Scale set agents** = a fleet of company vans that auto-park when idle and spin up when needed.

## Lab — Run a job on a self-hosted Docker agent

**Goal:** stand up a quick containerized agent and run a pipeline against it.

1. Get a PAT in Azure DevOps: **User Settings → Personal access tokens → New**: scope `Agent Pools (Read & manage)`.
2. Create a `default` pool if not already there: **Org Settings → Agent pools → Add pool → Self-hosted**.
3. Run an agent container:
   ```bash
   docker run -d \
     -e AZP_URL=https://dev.azure.com/<your-org> \
     -e AZP_TOKEN=<PAT> \
     -e AZP_POOL=default \
     -e AZP_AGENT_NAME=docker-agent-1 \
     -v /var/run/docker.sock:/var/run/docker.sock \
     mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-22.04
   ```
4. Confirm the agent appears as **Online** in the pool.
5. Update a pipeline to target it:
   ```yaml
   pool:
     name: default
   steps:
     - script: hostname && whoami
   ```
6. Run the pipeline. Confirm `hostname` returns your agent container name.
7. Now try a pipeline that uses Docker-in-Docker:
   ```yaml
   - script: docker run --rm hello-world
   ```
   Works because we mounted `/var/run/docker.sock`.
8. (Optional) Set up a VMSS-backed scale set pool — same idea, autoscaled.
9. Clean up: stop the container with `docker stop docker-agent-1`.

## Trainer notes

- Show the agent diagnostics under **Agent pools → Agents → Capabilities** — useful for debugging demand mismatches.
- Discussion: "Why not just always self-host?" — security responsibility, patching, baseline. Hosted is simpler for low scale.
- Common exam trap: agents on the same machine but in **different pools** need separate `config.sh` instances and separate folders.

## Next

➡ [Module 11 — Docker and Containers](11-docker-containers.md)
⬅ [Module 9 — YAML Pipelines and Templates](09-pipelines-yaml-templates.md)
