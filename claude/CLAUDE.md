I'm running Arch Linux with GNOME desktop.

Don't add the co-author section to the commit message.
Don't run git push unless I ask you to.

## About Me

DevOps/SRE engineer at Clario (via WITS), actively transitioning to
ML Infra / AI Platform Engineering (9-12 month plan).
Homelab: K8s cluster on Pi5 nodes + G14 GPU node (RTX 2060 via VFIO/KVM),
ArgoCD GitOps, Ollama + Qdrant + Langfuse on-cluster.
Key stack: Kubernetes, ArgoCD, Dynatrace, GitLab CI, Langfuse, Ollama, Qdrant.

## Projects

- `~/projects/clario/`   — work repos (Clario platform engineering)
- `~/projects/personal/` — personal repos (microlab homelab, RAG pipeline, etc.)

## Dotfiles

Managed via bare git repo at `~/.dotfiles`.
Alias: `dotfiles` = `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`
When working with dotfiles, use this alias.

## Language

Always respond in the same language the user writes in.
Match per message, not per session.

## Wiki Knowledge Base

Path: `~/sync-obsidian`

Personal knowledge base (Obsidian vault + Claude wiki system).

When I ask about my own projects, homelab, career, or work context:
1. Read `wiki/hot.md` first (recent context)
2. Read `wiki/index.md` if more structure is needed
3. Drill into `wiki/work/` or `wiki/personal/` as needed

For general technical questions unrelated to my personal setup: skip wiki reads.

## Auto-Update Rules (No User Action Required)

**hot.md** — auto-update at end of any session where:
- A technical decision was made
- A bug or gotcha was resolved
- A deployment or configuration change was completed
- New knowledge was learned or a misunderstanding was clarified
- Wiki content was deleted or significantly revised

Default to updating hot.md. The cost of an update is low; missing context is high.

**Wiki pages** — only create or modify when user explicitly says
`ingest`, `document this`, or `create a page`.

**index.md + log.md** — maintained automatically when wiki pages are created or deleted.
