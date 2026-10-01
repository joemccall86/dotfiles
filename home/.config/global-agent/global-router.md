# Workstation Persona Layer
Version: 1.1.0

## 1. Rule Precedence
If the current workspace directory contains local rules (e.g., `./CLAUDE.md`, `./.cursorrules`, or `./.cursor/rules/`), those local repo-level files take absolute priority over these global guidelines.

## 2. Core Profile Modules

**IMPORTANT — Version control**
Do not call `git` directly in a Jujutsu repo. A repo is jj if a `.jj` directory exists when walking up from the working dir (all my repos are jj+git colocated, so check for `.jj`'s presence, not `.git`'s absence). A PreToolUse hook auto-injects the jj rules when you run `git` in such a repo, but read `version-control-github.md` before any non-trivial VCS work regardless.

### 2.1 Always-Active Modules (embedded)

These modules are inlined into the prompt at session start via `@` import, so their rules are present in every session with no Read round-trip. They apply to all work, everywhere. If your client does not expand `@` imports, Read both files at session start instead.

**Communication & Tone**
@/Users/joe.mccall/.config/global-agent/instructions/persona.md

**Safety & Error Constraints**
@/Users/joe.mccall/.config/global-agent/instructions/guardrails.md

### 2.2 On-Demand Modules (progressive disclosure)

Load a module's file with the Read tool whenever the current task touches its topic — before acting, not after. These are not optional; the only conditionality is topic relevance.

- **Environment & Git Standards:** Read `~/.config/global-agent/instructions/workstation.md`
- **AWS Environment**: Read `~/.config/global-agent/instructions/aws-environment.md`
- **Documentation**: Read `~/.config/global-agent/instructions/documentation.md`
- **Go Coding Standards**: Read `~/.config/global-agent/instructions/go-coding-standard.md`
- **Version Control and GitHub**: Read `~/.config/global-agent/instructions/version-control-github.md`
- **acli Jira usage**: Read `~/.config/global-agent/instructions/acli-jira.md` (read BEFORE creating/editing/sprint-scoping any Jira work item with acli; includes the ADF formatting rules)
- **DuckDB for large CSV/data files**: Read `~/.config/global-agent/instructions/duckdb.md` (read BEFORE reading/searching any large CSV, TSV, Parquet, or JSON data file)
- **Slack**: Read `~/.config/global-agent/instructions/slack.md` (read BEFORE fetching, summarizing, or posting anything involving Slack)

## 3. Default Execution Guardrail
- Be highly concise. Never explain basic programming concepts or syntax changes unless explicitly requested.
- State the solution, output the clean code block, and stop.

