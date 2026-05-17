I'm running Arch Linux with GNOME desktop.

Don't add the co-author section to the commit message.
Don't run git push unless I ask you to.

Projects under `~/projects/clario/` are for work.
Projects under `~/projects/personal/` are personal repos.

## Language

Always respond in the same language the user writes in. If the user writes in Chinese, respond in Chinese. If the user writes in English, respond in English. Match per message, not per session.

## Wiki Knowledge Base
Path: ~/sync-obsidian

This is my personal knowledge base (Obsidian vault + Claude wiki system).
When I ask to save notes, ingest content, or query the wiki:
1. Read wiki/hot.md first (recent context)
2. Read wiki/index.md for structure
3. Drill into wiki/work/ or wiki/personal/ as needed
Update wiki/index.md, wiki/log.md, and wiki/hot.md after every ingest.

## Auto-Update Rules (No User Action Required)

Claude should update proactively — do not wait for the user to ask.

**hot.md — auto-update at the end of any session where one or more of the following occurred:**
- A technical decision was made (chose an approach, ruled out an option)
- A bug or gotcha was resolved
- A deployment or configuration change was completed
- New knowledge was learned or a misunderstanding was clarified
- Wiki content was deleted or significantly revised

**Wiki pages — only create or modify when:**
- The user explicitly says `ingest`, `document this`, or `create a page`
- There is enough new substance to warrant a standalone page (not casual conversation)

**index.md + log.md — maintained automatically by Claude when wiki pages are created or deleted. No user action needed.**

**Default to updating hot.md rather than skipping it. The cost of an update is low; the cost of missing context is high.**
