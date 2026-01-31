# PR Trigger Setup Guide

## Prerequisites
- Azure DevOps project with Azure Repos Git
- Pipeline YAML file committed to repository

## Step 1: Create the Pipeline
1. Go to **Pipelines → New Pipeline**
2. Select **Azure Repos Git**
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `workflow-examples/on-pr-run.yaml`
6. Click **Save** (not Run)

## Step 2: Configure Branch Policy
1. Go to **Repos → Branches**
2. Find `main` branch
3. Click **⋮** (more options) → **Branch policies**

### Build Validation
Under **Build validation** section:
1. Click **+ Add build policy**
2. Configure:
   - **Build pipeline**: Select your PR pipeline
   - **Trigger**: Automatic
   - **Policy requirement**: Required
   - **Build expiration**: Immediately
   - **Display name**: PR Validation
3. Click **Save**

### Optional Policies
| Policy | Description |
|--------|-------------|
| Require minimum reviewers | Require 1+ approvers before merge |
| Check for linked work items | Require work item association |
| Check for comment resolution | All comments must be resolved |
| Limit merge types | Allow only squash merge, etc. |

## Step 3: Test the Setup
1. Create a new branch: `feature/test-pr`
2. Make a change and push
3. Create a PR targeting `main`
4. Pipeline should trigger automatically
5. PR cannot be merged until pipeline passes

## How It Works
```
feature/test-pr → PR → main
                   ↓
            Pipeline Runs
                   ↓
         Pass: Can merge ✅
         Fail: Blocked ❌
```

## Important Notes
- **Branch Policy overrides YAML `pr:` trigger** when configured
- Pipeline runs on the **merge commit** (source + target combined)
- Failed builds block the merge button
- You can configure multiple build validations for different pipelines
