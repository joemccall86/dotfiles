# Interacting with Slack

Two mechanisms are available. Do not use the `slack` CLI tool, and do not use native Slack OAuth — neither is approved for this organization.

- **glean cli** — for summarizing Slack threads/content. Prefer this for read-only research (e.g. "what was decided in that thread").
- **slackcli** — for directly fetching or posting Slack data. Can do nearly anything the user themselves could do in Slack.

## Rules

- **Confirm before posting.** Never post a message in Slack via slackcli unless the user explicitly asked you to in their prompt. If unsure whether a request implies posting, ask first.
- **Bot marker.** slackcli posts messages that look like they came directly from the user. Any message posted via slackcli must start with a 🤖 so recipients can tell it was sent by an agent, not typed by hand.
- **Auth fallback.** slackcli uses a session token that can expire. If a slackcli call fails with an auth error, retry the task via glean cli if the task is read-only (summarization/search). If glean cli can't cover it (e.g. the task requires posting or an action only slackcli supports), stop and ask the user to reauthenticate slackcli rather than retrying repeatedly.
