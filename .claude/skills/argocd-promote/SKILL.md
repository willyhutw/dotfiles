---
name: argocd-promote
description: Promote ArgoCD infrastructure changes across environments (dev-int → val → prod). Use when promoting K8s/ArgoCD config changes between environments.
argument-hint: <repo> <source-env> <target-env> [component]
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# ArgoCD Promote Changes

Promote ArgoCD infrastructure changes across environments (dev-int → val → prod).

## Usage
/argocd-promote <repo> <source-env> <target-env> [component]

Examples:
- /argocd-promote clusters dev-int val
- /argocd-promote control-plane val prod dynatrace
- /argocd-promote onprem-cluster dev-int val

---

When this skill is invoked, follow these steps precisely:

## Step 1 — Understand the request

Parse the arguments:
- `repo`: one of `clusters`, `control-plane`, `onprem-cluster`
- `source-env`: one of `dev-int`, `val`, `prod`
- `target-env`: one of `val`, `prod`
- `component` (optional): limit the diff to a specific subdirectory under `infrastructure/`

Base path: `/home/willyhu/projects/clario/devops/argocd/`

## Step 2 — Environment value mappings

Use these mappings when adapting files for the target environment:

| Value | dev-int | val | prod |
|---|---|---|---|
| Env label in names | `devint` | `val` | `prod` |
| GitLab repoURL suffix | `dev-int/<repo>.git` | `val/<repo>.git` | `prod/<repo>.git` |
| AWS account ID | `136703005037` | `163627637315` | `361616343649` |
| SecretsManager IAM role (ClusterSecretStore) | `SecretsManagerReaderDevIntRole` | `SecretsManagerReaderValRole` | `SecretsManagerReaderProdRole` |
| ESO service account IAM role | `ESO-Access-Role` | `ESO-Access-Role` | `ESO-Access-Role` |
| Dynatrace hostGroup (control-plane) | `dev.infrastructure.k8s` | `val.infrastructure.k8s` | `prod.infrastructure.k8s` |
| Dynatrace hostGroup (clusters) | `dev.infrastructure.k8s` | `val.infrastructure.k8s` | `prod.infrastructure.k8s` |
| AWS Secrets Manager key prefix | `dev-int-argocd/` | `val-argocd/` | `prod-argocd/` |

## Step 3 — Diff the two environments

Run a recursive diff between:
- `<base>/<source-env>/<repo>/` and `<base>/<target-env>/<repo>/`
- If `component` is specified, limit to `infrastructure/<component>/`

Categorise each difference as one of:
- **Env-specific values only** (repoURL, account ID, names, etc.) — skip, expected
- **Structural difference** (file only in source, or meaningful content difference) — candidate for promotion

Present the list of candidates to the user and ask for confirmation before proceeding.

## Step 4 — Create a feature branch

In the target repo (`.git` is inside `<base>/<target-env>/<repo>/`):
```
git checkout -b feat/promote-<component-or-repo>-from-<source-env>
```

## Step 5 — Copy and adapt files

For each confirmed file to promote:
1. Copy content from source
2. Apply all relevant env value substitutions from the mapping table above
3. For `protect-core-namespaces.yaml`: update the environment-specific namespace names to match the target env (read the target's `namespaces/base/namespaces.yaml` to determine the correct names)
4. Write files to the target repo — do NOT commit yet

## Step 6 — Ask user to review

Show a summary of all new/modified files and their key changes.
Tell the user to review and confirm before committing.

## Step 7 — Commit (only after user confirms)

```
git add <files>
git commit -m "feat: promote <component> from <source-env> to <target-env>"
```

Do not push unless the user explicitly asks.

## Step 8 — Prompt skill review

After the commit, always remind the user:

> "Promotion complete! Please review `~/.claude/skills/argocd-promote/SKILL.md` to check if any new patterns or value mappings from this session should be added. Let me know and I'll update it for you!"
