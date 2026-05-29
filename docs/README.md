# AZ-400 — Sample Exam

A practice exam for the **Microsoft Certified: DevOps Engineer Expert (AZ-400)** exam, in two formats:

| Format | Best for |
|---|---|
| 🎮 **Interactive web simulator** ([index.html](index.html)) | Realistic exam experience with navigator, mark-for-review, submit & scoring. Deploy to GitHub Pages. |
| 📄 **Markdown with reveal-on-click answers** ([exam.md](exam.md)) | Reading on GitHub directly, printing, or studying offline. |

Both contain the **same 60 questions** covering all 7 AZ-400 domains, weighted heavily toward CI/CD (50-55% of the real exam).

---

## 🚀 Deploy the interactive simulator on GitHub Pages

The `docs/` folder is a self-contained static site.

### Option A: GitHub Pages from the repo (recommended)

GitHub Pages supports only two source folders: **root** (`/`) or **`/docs`**. This site uses **`/docs`**.

1. Push the repo to GitHub.
2. In the repo, go to **Settings → Pages**.
3. Under **Source**, choose **Deploy from a branch**.
4. Set **Branch** = `main`, **Folder** = `/docs`. Save.
5. After ~30 seconds, your exam will be live at:
   ```
   https://<your-user>.github.io/<repo-name>/
   ```
   (The `/docs` folder becomes the site root — no `/docs/` suffix in the URL.)

### Option B: Run locally

```bash
cd docs/
python3 -m http.server 8080
# then open http://localhost:8080/
```

(Direct `file://` access won't work because the page fetches `questions.json` — needs an HTTP server.)

---

## What the simulator looks like

- **Landing → Exam → Submit → Results → Review**
- One question per screen with progress in the header and a navigator on the right.
- Single-select, multi-select, true/false all supported.
- **Submit modal** warns about unanswered questions.
- **Results page**: animated score ring, **PASS** / **FAIL** (fail if < 70%), per-question color grid (green = correct, red = wrong).
- **Review mode** walks every question with your answer vs correct + explanation.
- **Retry** restarts fresh.

Fully responsive.

---

## Files

```
docs/
├── index.html              ← entry point (open this)
├── questions.json          ← the 60 questions
├── exam.md                 ← same questions, in Markdown
├── README.md               ← this file
├── .nojekyll               ← tells GitHub Pages to skip Jekyll
└── assets/
    ├── style.css           ← all CSS
    └── app.js              ← all JS
```

No external dependencies. No build step.

---

## Format match to the real exam

| Real exam | This sample |
|---|---|
| 40-60 questions in 120 min | 60 questions, untimed |
| MCQ + multi-select + case + drag/drop | MCQ + multi-select + scenarios |
| ~70% to pass (700/1000) | ≥ 42/60 |

## Question categories (matches April 2026 official weights)

| Domain | Weight | Questions |
|---|---|---|
| Processes and communications | 10-15% | 7 |
| Source control strategy | 10-15% | 7 |
| Continuous Integration (heaviest) | 20-25% | 14 |
| Continuous Delivery / release management | 10-15% | 8 |
| Security and compliance | 10-15% | 8 |
| Instrumentation strategy | 5-10% | 5 |
| SRE strategy | 5-10% | 5 |
| GitHub Actions + feature flags | cross-cutting | 6 |

## Disclaimer

Original questions modeled on the April 2026 skills outline. NOT taken from any live exam. Also use:
- AZ-400 practice: https://learn.microsoft.com/credentials/certifications/devops-engineer/practice/assessment

## Navigation

- ⬅ [Repo README](../README.md)
- ⬅ [Course content](../course-content/README.md)
- ⬅ [Exam prep guide](../course-content/exam-prep.md)
- 📄 [Markdown version of exam](exam.md)
- 🎮 [Launch interactive exam](index.html)
