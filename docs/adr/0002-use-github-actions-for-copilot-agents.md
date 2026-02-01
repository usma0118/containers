# ADR 0002 — Use GitHub Actions for Copilot Agents coordination

Date: 2026-02-01

Status: Proposed

## Context

The repository needs an automated coordinator to intake tasks from issues or external systems,
create branches and PRs, and comment on issues to coordinate work. GitHub Actions is already
available and suitable for this automation.

## Decision

We will use a GitHub Actions workflow (`.github/workflows/copilot-agents.yml`) as the
Copilot Agents coordinator. The workflow will listen for `issues`, `repository_dispatch`, and
`workflow_dispatch` events, create branches and PRs, and comment on issues. The workflow will
use the `GITHUB_TOKEN` with the following permissions: `contents: write`, `pull-requests: write`,
`issues: write`.

## Consequences

- Actions can create branches and PRs without external services, keeping automation in-repo.
- Branch protection or strict push rules may require a PAT or GitHub App instead of `GITHUB_TOKEN`.
- Reviewers should be defined via `.github/CODEOWNERS`; `@usma` is already assigned.
- Permissions should be reviewed periodically and tightened where possible.
