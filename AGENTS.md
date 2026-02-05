# Copilot Agents Runbook

Summary

- Runtime: GitHub Actions (workflows in `.github/workflows`).
- Primary permissions: create branches & open PRs; no automated merges.
- Task intake: GitHub Issues (agents will comment and track work on issues).
- Reviewer: `usma0118` — every PR requires human review and manual merge.

Agent Roles

- Implementation Planner: watches new tasks/issues, creates implementation branches/PRs, coordinates other agents.
- Task Planner: verifies research exists and produces implementation checklists.
- DevOps Expert: primary owner for Docker/container changes and CI/CD updates.
- ADR Generator: creates ADRs for architectural decisions and requires human approval.

Workflow (high level)

- New task created as a GitHub Issue (label `copilot-task` recommended).
- `Implementation Planner` agent (via Actions) picks the issue, creates an `agent/issue-<n>/implementation-plan` branch and creates a PR titled `WIP: Implementation plan for #<n>`.
- Agents will keep the issue updated by commenting and attaching plan artifacts. Major code changes are submitted as PRs; minor edits may be applied by agents in separate PRs.
- All PRs must be reviewed by `usma0118` and merged manually.

Files and locations

- Agent instruction files: .github/agents/
- Coordinator workflow: .github/workflows/copilot-agents.yml
- ADRs: docs/adr/

Branch & PR conventions

- Branch: `agent/issue-<NUMBER>/<short-description>`
- PR title: `WIP: Implementation plan for #<NUMBER>`
- PR body: include link to the originating issue and list agent(s) involved.

Security & Permissions

- Workflows are configured to give actions the minimum needed permissions: `contents: write`, `pull-requests: write`, `issues: write` so agents can create branches, PRs and comment on issues, but will not merge.
- To change behavior, update the workflow `permissions` block or replace `GITHUB_TOKEN` usage with a finer-scoped GitHub App.

How to trigger manually

- From the GitHub UI: open an issue or use the workflow dispatch for `Copilot Agents Coordinator`.
- Example using `gh` CLI:

```bash
gh workflow run "Copilot Agents Coordinator" --field issue_number=123
```

Triggering from chat or external systems

- The coordinator workflow also listens for `repository_dispatch` events so tasks started in chat or other automation can be processed by the same flow.

- When a chat system sends a `repository_dispatch` with a `client_payload` that includes either `issue_number` or a `task` field, the workflow will:
  - Create a GitHub Issue if `task` is present (the issue body will include the task text and any provided `chat_url`).
  - Create a branch and open a PR titled `WIP: Implementation plan for #<issue>`.
  - Comment on the issue and mention `@usma` as reviewer.

Example `repository_dispatch` payload (from chat automation):

```json
{
  "event_type": "copilot-task",
  "client_payload": {
    "title": "Fix Dockerfile for arm64",
    "task": "Container image fails on arm64. Please update Dockerfile and CI to build multi-arch images.",
    "chat_url": "https://chat.example.com/thread/abc123"
  }
}
```

Notes

- This lets agents operate on tasks given directly in chat while still preserving the repository-first workflow: every task is tracked as an issue and changes are proposed via PRs requiring human review.

Notes

- This runbook is a starting point — review `.github/agents/*` for agent-specific instruction files and customize as needed.
- Reviewer `usma0118` must be assigned as code owner or reviewer in the repo to ensure PRs are reviewed promptly.
