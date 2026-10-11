# ADR 0002 — Use GitHub Actions to coordinate Copilot planning

Date: 2026-02-01

Status: Proposed

## Context

The repository needs a controlled way to start planning from issues and external task sources.
GitHub Actions can validate task intake and assign an issue to Copilot cloud agent, while the
agent creates the plan pull request. The workflow's `GITHUB_TOKEN` cannot assign Copilot; the
assignment API requires a user-to-server token.

## Decision

We will use `.github/workflows/copilot-agents.yml` to accept only open issues labeled
`copilot-task`, including validated manual and repository-dispatch requests. The workflow uses
`GITHUB_TOKEN` with `issues: write` to validate or create issues and post status comments. It
uses the `COPILOT_AGENT_TOKEN` user-to-server secret to assign the repository's Copilot cloud
agent with planning-only instructions. Copilot creates a plan-only pull request;
the workflow does not push branches or create empty pull requests.

## Consequences

- Copilot cloud agent availability, account entitlement, and a user-to-server token are required.
- The token must have the permissions required by GitHub's Copilot issue-assignment API and
  must be stored as the `COPILOT_AGENT_TOKEN` Actions secret.
- `.github/CODEOWNERS` requests `@usma0118`; a repository ruleset or branch protection setting
  must separately require approval and code-owner review to enforce the human merge gate.
- The workflow processes planning only after explicit `copilot-task` opt-in, reducing unintended
  runs and preventing duplicate empty-branch creation.
