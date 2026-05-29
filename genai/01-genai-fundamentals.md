# 1 — GenAI Fundamentals

## What is generative AI?

**Generative AI** is a family of machine-learning models that **produce new content** — text, code, images, audio, video — rather than just classifying or predicting from existing content.

| "Traditional" ML | Generative AI |
|---|---|
| "Is this build flaky?" | "Write me a YAML pipeline that builds and deploys a Node app." |
| "Predict next month's traffic." | "Summarize last week's deployments and their impacts." |
| "Detect anomalies in metrics." | "Draft a postmortem from these incident notes." |
| Outputs a label/number | Outputs a paragraph/file/code |

### Why now?

Three things converged ~2017-2022:

1. **The transformer architecture** (2017 paper).
2. **GPU + data scaling** — bigger models keep getting better.
3. **Instruction tuning + RLHF** — making models actually helpful.

### Analogy: a very well-read junior engineer

Imagine a junior engineer who has read every public README, every YAML pipeline, every Stack Overflow answer. They can:
- Draft a pipeline in seconds.
- Mimic conventions they've seen.
- Recall patterns from outside your stack.

But they:
- Don't know your private setup.
- Confidently make things up sometimes.
- Have no real-world side effects unless you give them tools.

That's the right mental model.

## Common terms

| Term | Meaning |
|---|---|
| **LLM** | Large Language Model — predicts next text token |
| **Token** | A chunk of text (~3-4 chars) |
| **Context window** | How many tokens at once |
| **Prompt** | What you give the model |
| **System prompt** | App-defined instructions |
| **Hallucination** | Confidently false output |
| **Embedding** | Vector representation, for similarity search |
| **RAG** | Look up docs at query time, paste into prompt |
| **Fine-tuning** | Further training on your data |
| **Agent** | LLM with tools (read files, run commands, hit APIs) |
| **Multimodal** | Handles images / audio / video |

## What GenAI is good at (for DevOps)

- Drafting YAML pipelines, Dockerfiles, K8s manifests.
- Translating between CI systems (Jenkins → GitHub Actions).
- Writing or refactoring shell / PowerShell scripts.
- Summarizing CI logs, identifying error patterns.
- Drafting KQL or PromQL queries.
- Writing incident postmortems from raw notes.
- Generating runbooks and docs.

## What GenAI is NOT good at

- Truly novel design without enough context.
- Strict mathematical reasoning (cost forecasts, capacity).
- Knowing what's true in *your* environment.
- Being sure when it's wrong.
- Replacing review and judgment — especially for security-sensitive changes.

## Implication for DevOps engineers

- More leverage per engineer. A platform team of 3 can support 30 dev teams.
- Less typing, more reviewing and curating.
- New failure modes — hallucinated YAML keys, plausible-but-wrong K8s spec, fabricated `az` command syntax — that you need to catch.
- A bigger premium on **observability** and **rollback safety**, because more changes ship per day.

## Navigation

- ⬅ [GenAI index](README.md)
- ➡ [Module 2 — LLMs Explained](02-llms-explained.md)
