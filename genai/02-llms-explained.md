# 2 — LLMs Explained

## What an LLM does

A **Large Language Model** does one thing: given some text, predict the most likely next chunk of text.

That's it. Everything — chat, code completion, doc Q&A — is built by feeding the model the right inputs and reading its outputs cleverly.

### Analogy: incredibly aggressive autocomplete

Your phone's autocomplete suggests one word. An LLM is the same idea, but:
- Trained on billions of words.
- Predicts the next 1000s of tokens at a time.
- Pays attention to *all* the words before, not just the last one.

That's why it can write a whole CI pipeline: it's "autocompleting" the file from millions of similar files seen during training.

## The transformer

Modern LLMs use the **transformer architecture**. The key idea is **attention** — for every token, the model can look back at any previous token and decide how much it matters.

Compared to older RNN models, transformers:
- Look at all tokens in parallel.
- Pay attention to anything relevant.
- Run very fast on GPUs.

## Tokens, not words

LLMs operate on tokens (~3-4 chars each). Whitespace counts. This matters because:
- Pricing is per token.
- Context limits are in tokens.
- Models do math on token IDs, not English.

## Training stages

1. **Pre-training** — model sees trillions of tokens of internet text.
2. **Supervised fine-tuning** — humans write good responses to prompts; model imitates.
3. **RLHF / preference tuning** — humans rank outputs; model learns what people prefer.

The result is a **chat-tuned model** — shaped to be a helpful assistant.

## Why LLMs hallucinate

The model's job is to produce **plausible-sounding text**. It has no separate "truth" signal.

How to reduce hallucination:
- **Ground** the model with RAG (paste docs into the prompt).
- **Give it tools** — let it run a command or query a system.
- **Ask for citations** — and verify.
- **Use lower temperature** for factual tasks.

## Context window

Most important number per model:

- GPT-3.5 (2022): 4k tokens.
- GPT-4 (2023-24): 8k → 32k → 128k.
- Claude Sonnet (2024): 200k.
- Claude Opus 4.x (2025-26): 200k+ with extended caching.
- Gemini 1.5 Pro: 1-2 million tokens.

Bigger context = the model can read more of your pipeline / codebase at once.

## Frontier model families (mid-2026)

| Family | Vendor | Strengths |
|---|---|---|
| **Claude** | Anthropic | Coding, long context, careful reasoning |
| **GPT** | OpenAI / Azure OpenAI | Broad capability |
| **Gemini** | Google | Massive context, multimodal |
| **Llama** | Meta (open weights) | Self-hostable |
| **Phi** | Microsoft (open) | Small, edge-friendly |

For DevOps tasks (writing YAML, scripts, KQL, Bicep) all the leaders work well. Claude has been particularly strong at multi-file agentic edits and tool use.

## The "agent" leap

A bare LLM is a function: text in, text out. An **agent** is an LLM that can:

1. Read its environment (files, logs, CI configs).
2. Decide on an action.
3. Call a tool (write a file, run a CLI, query an API).
4. Observe the result.
5. Loop until done.

This is what GitHub Copilot Workspace, Claude Code, and Cursor Composer are doing. Module 3 compares them.

## Navigation

- ⬅ [Module 1 — GenAI Fundamentals](01-genai-fundamentals.md)
- ➡ [Module 3 — Coding Agents Overview](03-coding-agents-overview.md)
