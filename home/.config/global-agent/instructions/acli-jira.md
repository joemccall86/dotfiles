# acli Jira Usage

Version: 2.1.0

Complete reference for the Atlassian Cloud CLI (`acli`) against Jira at
`includedhealth.atlassian.net`: authentication, work item CRUD, boards/sprints,
sprint-scoped APL creation, and the ADF formatting rules that make
descriptions/comments render as real markup instead of literal text.

`acli` also has `confluence`/`space`/`page`, `admin`, `rovodev`, and `config`
command groups; Jira is the relevant one for day-to-day work.

## Authentication

```bash
acli jira auth status    # which account/site is active
acli jira auth login     # OAuth flow to the Atlassian host
acli jira auth switch    # multiple accounts
acli jira auth logout
```

The top-level `acli auth login|status|switch|logout` are the global equivalents
covering all products; the Jira-scoped commands are what to check for Jira work.

## CRITICAL: run write ops with the sandbox DISABLED

`acli` writes hit `https://includedhealth.atlassian.net`, which is **not** in
the Claude Code command sandbox's network allowlist. Sandboxed writes fail with
opaque errors:

- `✗ Failure: <KEY> can't be edited: unknown error`
- `"status": "FAILURE", "message": "unknown error"`
- `✗ Error: failed to fetch work item details`

These are NOT acli/ADF bugs — they are the sandbox blocking the host. Run any
`create` / `edit` / `comment` / `transition` / `assign` (and multi-field `view`)
with `dangerouslyDisableSandbox: true`. Single-field reads like
`view --fields status` happen to work sandboxed; do not rely on that.

## Work item commands

```
acli jira workitem <command>
```

Targeting is uniform across create-like commands: pick ONE of
`--key "KEY-1,KEY-2"`, `--jql "project = APL"`, `--filter <id>`, or
`--from-file issues.txt` (keys/IDs separated by commas, spaces, or newlines).
Add `--yes` to skip the confirmation prompt, `--json` for machine-readable
output, and `--ignore-errors` to keep going on multi-item failures.

| Command | Purpose | Key flags |
|---------|---------|-----------|
| `view [key]` | Fetch a work item | `--fields summary,comment` (comma list; prefix `-` to exclude; `*all`/`*navigable`), `--json`, `--web` |
| `search` | Query by JQL/filter | `--jql`, `--filter`, `--fields` (default `issuetype,key,assignee,priority,status,summary`), `--limit`, `--paginate`, `--count`, `--csv` |
| `create` | Create one item | `-p` project, `-t` type (Epic/Story/Task/Bug), `-s` summary, `-a` assignee, `-l` labels, `--parent`, `-d` / `--description-file` (ADF), `--from-json` / `--generate-json` |
| `create-bulk` | Bulk create | `--from-json` / `--from-csv` / `--generate-json` |
| `edit` | Edit one or many | `--summary`, `-a` assignee, `--remove-assignee`, `-d` / `--description-file` (ADF), `--labels` / `--remove-labels`, `-t` type, `--yes` |
| `comment create` | Add comment | `--body` or `--body-file` (text or ADF), `--edit-last` amend latest from same author, `--editor` |
| `comment list` | List comments | `--key`, `--limit`, `--order +created`, `--paginate` |
| `comment update` | Edit a comment | `--key` + `--id` (comment ID), `--body` / `--body-adf` / `--body-file`, `--visibility-role` / `--visibility-group`, `--notify` |
| `comment delete` | Delete a comment | `--key` + `--id` |
| `transition` | Move to a status | `--status "Done"`, `--yes` |
| `assign` | Change assignee | `--assignee` email (current user: `"$USER"@includedhealth.com`) / account ID, `--remove-assignee` — **never** `@me` (see Assignee) |
| `link create` | Link two items | `--out KEY-1 --in KEY-2 --type <LinkType>` (see `link type` for valid types) |
| `link list` | List links on a key | `--key`, `--json` |
| `link delete` | Delete a link | `--id` (link ID from `link list`), `--from-json` / `--from-csv` |
| `link type` | Available link types | `--json` |
| `attachment list` | List attachments | `--key`, `--json` |
| `attachment delete` | Delete attachment | `--id` (attachment ID from `attachment list`) |
| `watcher add/remove` | Watchers | `--key`, `--user` / `--email` (`remove` only) |
| `list-watchers` | List watchers | `--key` |
| `clone` | Duplicate item(s) | `--to-project`, `--to-site` (cross-site), `--yes` |
| `archive` / `unarchive` | Archive / restore | `--yes` |
| `delete` | Delete (soft) | `--yes` |

Every command also supports `--help` for its exact flags. Generates editable
JSON scaffolds for `create` and `edit` with `--generate-json`, then pass the
filled file back via `--from-json`.

### Common shapes

```bash
# Create
acli jira workitem create -p DP -t Bug -s "Title" -a "${USER}@includedhealth.com" --description-file desc.adf.json --json

# View a subset of fields
acli jira workitem view DP-6583 --fields summary,assignee,status --json

# Find items
acli jira workitem search --jql "project = APL AND assignee = me" --fields key,summary,status --json

# Comment (ADF or plain text body)
acli jira workitem comment create --key DP-6583 --body "done, see PR"

# Status
acli jira workitem transition --key DP-6583 --status "Done" --yes
```

## Assignee: never use `@me`

`@me` is **not** a special token for acli. It gets routed to a fuzzy person
finder, which can resolve to a completely different person (it has
auto-assigned a ticket to a colleague named Megs). Always assign to the
current user's explicit email:

```bash
MY_EMAIL="${USER}@includedhealth.com"   # e.g., joe.mccall@includedhealth.com
```

Use it in every assignment path:

- `create` / `edit`: `-a "$MY_EMAIL"`
- `assign`: `--assignee "$MY_EMAIL"`
- `create`/`edit` `--from-json` envelope: `"assignee": "<MY_EMAIL>"`
  (substitute the resolved email, as in the APL example above)

Verify the assignee after every write:

```bash
acli jira workitem view KEY --fields assignee --json
```

and confirm the returned `emailAddress`/`name` matches `$MY_EMAIL`. If it
does not, re-assign immediately with the explicit email.

JQL `assignee = me` (in `search --jql`) is fine — Jira evaluates it
server-side, so it does not go through acli's fuzzy finder.

## Boards and sprints

```
acli jira board <command>     acli jira sprint <command>
```

| Command | Purpose | Key flags |
|---------|---------|-----------|
| `board search` | Find boards | `--project APL` (JQL relevance), `--type scrum`/`kanban`/`simple`, `--name`, `--json`, `--limit`, `--paginate` |
| `board view` | Board details | `--id 8051`, `--json` |
| `board list-sprints` | Sprints on a board | `--id 8051`, `--state active` (also `future`, `closed`; comma-separate), `--limit`, `--json` |
| `sprint view` | Sprint details | `--id`, `--json` |
| `sprint list-workitems` | Issues in a sprint | `--board 8051` + `--sprint <id>` (both required), `--jql`, `--fields`, `--json` |
| `sprint create` / `update` / `delete` | Manage sprints | see `--help` |

There is **no `--sprint` flag on `workitem create` / `edit`** — sprint scoping
goes through the board's Sprint custom field (see below).

## Jira: create an APL work item in the current sprint (`acli`)

`acli jira workitem create` does not have a `--sprint` flag. Scope into a sprint
at create time via `--from-json` and the Sprint custom field.

### Field and board (Application Platform)

| What | Value |
|------|--------|
| Project | `APL` |
| Sprint field | `customfield_10010` |
| Scrum board | `8051` (`App Platform Scrum`) — from `acli jira board search --project APL --json` |

### Resolve the active sprint ID

```bash
acli jira board list-sprints --id 8051 --state active --json
```

Use the sprint `id` (integer). Prefer the sprint already used by recent APL
tickets (e.g. view `customfield_10010` on a sibling item) when multiple
sprints are `active` on the board.

### Create assigned + sprint-scoped

Pass ADF (not Markdown/wiki) for the description. Set sprint as a bare number
under `additionalAttributes`:

```json
{
  "projectKey": "APL",
  "type": "Task",
  "summary": "short summary",
  "assignee": "joe.mccall@includedhealth.com",
  "description": { "type": "doc", "version": 1, "content": [ /* ADF */ ] },
  "additionalAttributes": {
    "customfield_10010": 28011
  }
}
```

```bash
acli jira workitem create --from-json /path/to/payload.json --json
```

Assignee is always the current user's explicit email — never `@me` (see Assignee). Verify with:

```bash
acli jira workitem view KEY --fields 'summary,assignee,customfield_10010,status' --json
```

Sprint membership can show while status remains `Backlog`; that still counts as
scoped into the sprint.

### Notes

- Run create/edit/comment with network unrestricted (sandbox blocks Atlassian).
- Descriptions: ADF only — see Formatting (ADF) below. Wiki/Markdown become
  literal text.
- To sprint-scope an existing item, edit via `--from-json` with the same
  `customfield_10010` additional attribute (or the Jira Agile API); `workitem edit`
  CLI flags alone do not expose sprint.

## Formatting: ADF only

How to make `acli jira workitem` descriptions/comments render with real
headings, bold, code spans, lists, and links — instead of showing raw markup.

### Root cause of broken formatting

`acli`'s `--description` / `--description-file` / `--body` / `--body-file`
flags accept **plain text OR Atlassian Document Format (ADF) JSON only**. They
do **not** interpret:

- Jira wiki markup — `h2. Title`, `*bold*`, `{{code}}`, `* bullet`
- Markdown — `## Title`, `**bold**`, `` `code` ``, `- bullet`

If you pass either of those, acli stores the whole string verbatim as a single
ADF `paragraph` containing one `text` node. The result renders literally: you
see `h2. Summary` and `{{false}}` as plain text on the ticket. This is the bug
seen on DP-6583.

### Fix: supply an ADF JSON document

Build an ADF doc (`{"version":1,"type":"doc","content":[...]}`) and pass it via
`--description-file`. acli detects valid ADF JSON and uses it as rich content.

```bash
# Create
acli jira workitem create -p DP -t Bug -s "Title" --description-file desc.adf.json

# Edit existing
acli jira workitem edit --key DP-6583 --description-file desc.adf.json --yes

# Or via --from-json envelope (note: "issues" plural + nested "description")
#   { "issues": ["DP-6583"], "description": { ...ADF doc... } }
acli jira workitem edit --from-json edit.json --yes
```

Generate the from-json template with: `acli jira workitem edit --generate-json`.

### ADF cheat-sheet (node/mark → JSON)

| Want                | ADF |
|---------------------|-----|
| H2 heading          | `{"type":"heading","attrs":{"level":2},"content":[{"type":"text","text":"Summary"}]}` |
| Paragraph           | `{"type":"paragraph","content":[{"type":"text","text":"..."}]}` |
| Bold                | text node + `"marks":[{"type":"strong"}]` |
| Inline code (`x`)   | text node + `"marks":[{"type":"code"}]` |
| Link                | text node + `"marks":[{"type":"link","attrs":{"href":"https://..."}}]` |
| Bullet list         | `{"type":"bulletList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[...]}]}]}` |
| Code block          | `{"type":"codeBlock","attrs":{"language":"go"},"content":[{"type":"text","text":"..."}]}` |

Marks combine on one text node: `"marks":[{"type":"strong"},{"type":"code"}]`.

### Wiki-markup → ADF translation (when porting old descriptions)

- `h2. X`            → `heading` level 2
- `*X*`              → `strong` mark
- `{{X}}`            → `code` mark
- `* item`           → `bulletList` / `listItem`
- bare URL           → `link` mark (set both the visible `text` and `href`)

### Reusable build pattern

Authoring full ADF by hand is verbose. Practical approach: write the ADF JSON
to a temp file (`/tmp/claude/<KEY>.adf.json`), or build it programmatically — a
small script can convert a Markdown/section structure into ADF nodes, then feed
the result to `--description-file`. Verify afterward with:

```bash
acli jira workitem view <KEY> --fields description --json   # (sandbox disabled)
```

and confirm `heading`/`code`/`link` node types are present (not one giant
`paragraph` text blob).
