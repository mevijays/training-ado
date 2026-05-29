# Module 11 — Docker and Containers

> **AZ-400 domain:** Define and implement continuous integration.

## Why this matters

Almost every modern CI pipeline produces a container image. The exam tests Dockerfile knowledge and pipeline integration.

## Theory

### What a container is

A **container** is an OS process with a private view of the filesystem, network, and process namespace, sharing the host kernel. It's the artifact format for modern apps.

### Image vs container

- **Image** = read-only template (like a class).
- **Container** = a running instance of an image (like an object).

### Dockerfile

A recipe to build an image:

```dockerfile
# Multi-stage build for a Node app
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json .
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

Key directives:

| Directive | Purpose |
|---|---|
| `FROM` | Base image |
| `WORKDIR` | `cd` for subsequent steps |
| `COPY` / `ADD` | Bring files into the image |
| `RUN` | Execute a command at build time |
| `ENV` | Set environment variable |
| `EXPOSE` | Document a port |
| `USER` | Drop privileges |
| `ENTRYPOINT` / `CMD` | What to run when the container starts |
| `HEALTHCHECK` | How Docker tests container health |

### Multi-stage builds

Two key benefits:
- Final image is tiny (no toolchains).
- Cleaner caching (RUN layers in build stage are reusable).

### Image layers

Each `RUN`/`COPY`/`ADD` creates a layer. Order them from **least to most frequently changing** — top of file = stable; bottom = often changing. This maximizes cache hits.

### Tagging

```bash
docker build -t myorg/api:1.2.3 -t myorg/api:latest .
docker push myorg/api:1.2.3
docker push myorg/api:latest
```

Tag rules:
- `latest` floats — never deploy `:latest` to prod.
- Use immutable tags: commit SHA, semver.
- Often dual-tag: `:v1.2.3` and `:abc1234`.

### `docker compose`

Multi-container local dev:

```yaml
services:
  api:
    build: .
    ports: ["3000:3000"]
    environment:
      DB_URL: postgres://db:5432/app
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: secret
```

`docker compose up` runs both.

### Image security

Best practices:

| Do | Don't |
|---|---|
| Use minimal base images (alpine, distroless) | `FROM ubuntu:latest` |
| Pin base image by SHA | `FROM ruby` |
| Run as non-root (`USER appuser`) | `USER root` |
| Scan images (Trivy, Snyk, Defender) | Trust upstream blindly |
| Sign images (Notary, Sigstore) | Push unsigned |
| One process per container | "Multi-app monolith image" |

### Tools

- **Docker Desktop / Engine** — build and run.
- **BuildKit** — modern builder, parallel + secrets-aware.
- **buildx** — multi-platform builds (arm64 + amd64 in one command).
- **podman** — daemonless alternative.

### Analogy

- Image = a frozen pizza.
- Container = a pizza being eaten.
- Registry = the supermarket freezer.
- Dockerfile = the pizza recipe.

## Lab — Containerize and push

**Goal:** build a multi-stage Node image and push to ACR.

1. Sample app:
   ```bash
   mkdir bookstore-api && cd bookstore-api
   npm init -y
   npm i express
   cat > index.js <<'EOF'
   const express = require('express');
   const app = express();
   app.get('/', (_, res) => res.json({ ok: true, hostname: require('os').hostname() }));
   app.listen(3000, () => console.log('Listening on 3000'));
   EOF
   ```
2. `Dockerfile`:
   ```dockerfile
   FROM node:20-alpine AS deps
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --omit=dev

   FROM node:20-alpine
   WORKDIR /app
   COPY --from=deps /app/node_modules ./node_modules
   COPY . .
   USER node
   EXPOSE 3000
   CMD ["node", "index.js"]
   ```
3. Build + run locally:
   ```bash
   docker build -t bookstore-api:dev .
   docker run -p 3000:3000 --rm bookstore-api:dev
   curl localhost:3000
   ```
4. Create an Azure Container Registry:
   ```bash
   az group create -n rg-acr-lab -l eastus
   az acr create -g rg-acr-lab -n acr$RANDOM --sku Basic
   ACR=$(az acr list -g rg-acr-lab --query "[0].name" -o tsv)
   az acr login -n $ACR
   ```
5. Tag + push:
   ```bash
   docker tag bookstore-api:dev $ACR.azurecr.io/bookstore-api:1.0.0
   docker push $ACR.azurecr.io/bookstore-api:1.0.0
   ```
6. List in ACR:
   ```bash
   az acr repository list -n $ACR -o table
   az acr repository show-tags -n $ACR --repository bookstore-api -o table
   ```
7. (Optional) Use `docker buildx` for multi-arch:
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 -t $ACR.azurecr.io/bookstore-api:multi --push .
   ```
8. Clean up: `az group delete -n rg-acr-lab --yes`.

## Trainer notes

- Spend a few minutes on layer caching — students underestimate how much `COPY package*.json ./ && RUN npm ci` before `COPY .` saves.
- Discussion: "Distroless vs Alpine vs Ubuntu?" — Distroless wins on size/security; Alpine on community; Ubuntu on debugging ease.
- Common exam trap: `:latest` tag is mutable; pipelines must use immutable tags for traceability.

## Next

➡ [Module 12 — Container Registries (ACR)](12-container-registries.md)
⬅ [Module 10 — Self-hosted Agents](10-self-hosted-agents.md)
