# Workstation Coding Guardrails

- **No Placeholders:** Never use comments like `// TODO: Implement` or `// ... rest of code`. Output the complete logic.
- **Robustness:** All asynchronous calls must be wrapped in explicit try/catch blocks with clean logging.
- **Refactoring:** When changing a file, check for dead imports or unused variables and strip them out dynamically.
- **No Session Narration:** Code comments and documentation describe the current state of the code only — never prior work, what changed, why it differs from before, or the task/session that produced it (no "fixed X", "per review feedback", "previously this did Y", "removed Z"). Reviewers, human or agent, see only the code as it stands; they have no access to the session that wrote it and don't need it — that context belongs in the commit/PR description, not the file.
