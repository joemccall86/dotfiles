# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is not an application codebase — it's Joe McCall's **global Claude Code persona/instruction layer**. It has no build, lint, or test commands; the only "correctness" here is whether the markdown content is accurate and whether the routing/loading rules are internally consistent.

The repo is referenced from `~/.claude/CLAUDE.md` ("Workstation Persona Layer"), which is injected into every Claude Code session on this machine regardless of working directory. That top-level file is the actual entry point; this repo holds the module content it points to.

## Architecture: instruction module loading

`global-router.md` mirrors the module table embedded in `~/.claude/CLAUDE.md` §2. The core design principle: **modules are loaded on demand, by topic relevance, before acting on a task** — not all read upfront on session start. Two always-active modules (persona, guardrails) are the exception: `global-router.md` embeds them via `@` import so their rules sit in every session prompt. Each row maps a topic to a file under `instructions/`; the `Load` column says how it reaches the prompt.

| Topic | File | Load |
|---|---|---|
| Communication & tone | `instructions/persona.md` | embedded (`@` import — every session) |
| Safety & error constraints | `instructions/guardrails.md` | embedded (`@` import — every session) |
| Environment & git standards (OS/shell) | `instructions/workstation.md` | on-demand (`Read` before acting) |
| AWS auth (`tng`/`tngctl`, `aws-environment`) | `instructions/aws-environment.md` | on-demand (`Read` before acting) |
| Documentation (Diataxis framework) | `instructions/documentation.md` | on-demand (`Read` before acting) |
| Go doc/comment conventions | `instructions/go-coding-standard.md` | on-demand (`Read` before acting) |
| Version control & GitHub (Jujutsu-first) | `instructions/version-control-github.md` | on-demand (`Read` before acting) |
| Jira work items via `acli` (incl. ADF formatting) | `instructions/acli-jira.md` | on-demand (`Read` before acting) |
| Large CSV/TSV/Parquet/JSON via DuckDB | `instructions/duckdb.md` | on-demand (`Read` before acting) |
| Slack (glean cli / slackcli) | `instructions/slack.md` | on-demand (`Read` before acting) |

When editing this repo, keep `global-router.md` and the module table in `~/.claude/CLAUDE.md` in sync — they're meant to be the same list in two places.

## Cross-cutting rules that apply everywhere

These come from `instructions/persona.md` and `instructions/guardrails.md` and apply regardless of which module triggered a read:

- Be concise; no conversational filler. For ambiguous requests, present at most two paths with a recommendation and ask for a one-word confirmation.
- **Attribution rule:** any content authored under Joe's identity for an audience other than Joe himself (PR/issue comments, commit/PR text, Slack, email, Jira) must carry an attribution line, e.g. `🤖 Claude — per Joe McCall's direction`.
- No placeholder code (`// TODO`, `// ... rest of code`); output complete logic.
- Async calls need explicit try/catch with clean logging.
- When editing a file, strip dead imports/unused variables encountered along the way.

## Version control note

`instructions/version-control-github.md` assumes **Jujutsu (`jj`)**, colocated with Git, as the default VCS for Joe's repos — `git` is only used directly when explicitly instructed. The precedence rule lives in `~/.claude/CLAUDE.md`: detect `jj` by walking up for a `.jj` directory (not by the *absence* of `.git`, since jj/git are colocated). Key conventions from that module:
- Bookmarks (not branches) map to GitHub PRs: `jj bookmark create task/DP-1234/slug`.
- Commit/bookmark names embed the Jira work item key; use `acli` to look up whether it's a task/bug/feature (bugs use "fix" in the slug).
- Lint via `jj pc` on an empty commit, then `jj squash` into the parent — up to 5 fix/retry cycles before reporting failure.

## Tool-specific gotchas worth knowing before use

- **acli Jira writes:** `--description`/`--description-file` only accept plain text or ADF JSON — Markdown and Jira wiki markup get stored verbatim and render broken. Build real ADF JSON. Also, `create`/`edit`/`comment`/`transition` calls must run with the sandbox disabled (`dangerouslyDisableSandbox: true`) since `acli` hits `includedhealth.atlassian.net`, which sandboxed Bash can't reach.
- **AWS environment:** never hand-set `AWS_ENVIRONMENT`; run `aws-environment uat dev` to load credentials instead. Never run `aws-environment production dev` or `aws-environment uat platform`.
- **Slack:** no native Slack OAuth or the bare `slack` CLI — use `glean cli` for read-only summarization and `slackcli` for anything requiring direct fetch/post. Never post without explicit user instruction, and prefix any posted message with 🤖.
- **Large data files:** never `Read`/`cat`/`grep` a large CSV/TSV/Parquet/JSON directly — query it with `duckdb -c "..."` (or a scratch `.sql` file for multi-statement work) and bring only query results into context.
