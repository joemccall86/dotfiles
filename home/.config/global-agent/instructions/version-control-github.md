# Version Control & GitHub Workflow Guidelines (Jujutsu / jj)

Unless stated otherwise, this repository uses **Jujutsu (`jj`)** as its version control system, colocated with Git. Do **NOT** use standard `git` commands (e.g., `git status`, `git add`, `git commit`) unless explicitly instructed. All version control actions must be performed using `jj`.

---

## 1. Core Workflow Mapping
Jujutsu tracks working copy changes automatically. You do not need to "stage" files.

* **Check Status:** Use `jj status` instead of `git status`.
* **View History/Log:** Use `jj log` instead of `git log`.
* **Amending/Saving Work:** `jj` automatically creates working copy commits. To describe your current changes, use:
    ```bash
    jj describe -m "Your commit message"
    ```
* **Creating New Changes (Branches):** Instead of `git checkout -b branch-name`, use:
    ```bash
    jj new -m "Description of new task"
    ```
* **Syncing with Git Remote:** * To pull: `jj git fetch`
    * To push: `jj git push`

### Rules for Agent Behavior
1. **Do not look for `.git` configuration** to determine repository state. Rely on `jj status`.
2. **Never run `git commit`.** If you need to checkpoint your work, simply use `jj describe -m "progress update"`. If you need to split work, use `jj new`.
3. **File Modifications:** Since `jj` tracks the working copy in real-time, snapshotting is automatic. You only need to edit the files; you do not need to run an "add" command for modified files. For *new* files, `jj` will track them automatically unless they are ignored.

## 1a. Linting/Formatting
Our projects have pre-commit integrated into Git automatically, but not Jujutsu.

To lint/format the code on a particular commit:
* Start with a new empty commit
* Run `jj pc`, which automatically runs pre-commit on all the files changed in this commit versus main/master (jj pc is defined in ~/.config/jj/config.toml)
* Fix any errors that were not auto-fixed by pre-commit.
* Rinse/repeat until `jj pc` returns success, up to 5 times on the same failure before reporting back failure.
* Squash the pre-commit changes to the parent commit by running `jj squash`, making it look like the code was compliant from the beginning.

## 1b. Bookmark naming/formatting
In this section, DP-1234 is a sample work item name. Substitute the actual work item name.

Work is done on Jira work items. Prompt the user for the Jira work item number and format the bookmarks as such:

`jj bookmark create task/DP-1234/sample-work-item`

Use the installed `acli` tool to discover the type of the work item given to you, e.g., task, bug, feature. If it is a bug, use the word "fix" instead of "bug".

## 1c. Commit messages

- Write a summary line, followed by a blank line, followed by a more detailed description
- Summarize what was done, and briefly why
- Be concise, and use bullet points where necessary
- Summary line should include the work item number.

Example commit message:

```text
[DP-1234] Did some work stuff

- Re-factored x, y, and z
- Did something else
```

---

## 2. GitHub Pull Request (PR) Workflow

When creating or updating Pull Requests on GitHub, do **NOT** use standard `git push origin branch-name`. Instead, use **Bookmarks** in Jujutsu to map your revisions to GitHub branches.

* **Preparing a PR (Creating a Bookmark):** Before pushing, you must assign a bookmark (which Git sees as a branch) to your current change:
    ```bash
    jj bookmark create my-feature-name
    ```
* **Pushing the PR to GitHub:**
    Push the bookmark to the remote repository. This will automatically make it visible to GitHub for a PR:
    ```bash
    jj git push --bookmark my-feature-name
    ```
* **Updating an Existing PR:**
    Because `jj` uses standard rebases and amends, updating a PR is seamless. Simply make your edits, ensure you are on the change with the bookmark, and run:
    ```bash
    jj git push --bookmark my-feature-name
    ```
    *(Note: `jj` handles the force-pushing under the hood safely if the history has mutated).*
* **Creating the PR via CLI:**
    Using the installed `gh` cli, you can open the PR after pushing by running:
    ```bash
    gh pr create --head my-feature-name --title "[DP-1234] Your PR Title" --body "Your PR Description"
    ```

### Rules for Agent PR Management
1. **Always track bookmarks:** Never attempt to push an "anonymous" `jj` revision to GitHub. Always create a descriptive bookmark first.
2. **Do not use `git push -f`:** If a PR needs updating after a rebase or a `jj squash`, simply use `jj git push --bookmark [name]`. Jujutsu will safely update the remote state without needing Git's force flags.
