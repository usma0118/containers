<!-- mermaid-ai-skills:start -->

# Copilot Agents Runbook

## Summary

The coordinator is `.github/workflows/copilot-agents.yml`. It starts planning only for an open issue labeled `copilot-task`, then assigns the Copilot cloud agent to create a plan-only pull request. It does not create empty branches or PRs itself.

## Agent Roles

- Implementation Plan Generation Mode: `.github/agents/implementation-plan.agent.md`; creates an implementation plan and must not implement it.
- DevOps Expert: `.github/agents/devops-expert.agent.md`; provides DevOps and CI/CD guidance.
- ADR Generator: `.github/agents/adr-generator.agent.md`; creates architectural decision records.

## Workflow

1. Create an issue and add the `copilot-task` label. The coordinator ignores issues until this label is applied.
2. The workflow assigns Copilot cloud agent with planning-only instructions that point it to `.github/agents/implementation-plan.agent.md`. It asks for one plan file under `plan/`; the plan file must be the only repository change.
3. Copilot opens the plan pull request. `.github/CODEOWNERS` requests `@usma0118` for matching changes.
4. Require pull requests, at least one approval, and code-owner review in a ruleset or branch protection for the default branch. Merge manually after review; these repository settings are not enforced by the workflow.

## Files and Locations

- Agent profiles: `.github/agents/`
- Coordinator workflow: `.github/workflows/copilot-agents.yml`
- ADRs: `docs/adr/`
- Generated plans: `plan/`

## Security and Permissions

- The workflow's `GITHUB_TOKEN` is limited to `issues: write` for issue validation, chat-task issue creation, and status comments. It does not push branches or create pull requests.
- Add a `COPILOT_AGENT_TOKEN` Actions secret containing a user-to-server token authorized to assign Copilot cloud agent. GitHub's fine-grained token requirements include read metadata and read/write access to Actions, Contents, Issues, and Pull requests. Do not use a server-to-server installation token; the Copilot assignment API does not support it.
- Copilot cloud agent must be enabled for the repository and account. The workflow fails with an explicit error if Copilot is unavailable or the token is missing.
- Only trusted automation should be allowed to send the `copilot-task` repository-dispatch event. External task payloads are treated as issue content, not as authorization.

## Triggering

- Manually dispatch the workflow for an existing open issue labeled `copilot-task`:

```bash
gh workflow run "Copilot Agents Coordinator" --field issue_number=123
```

- For a new chat task, send the `copilot-task` repository-dispatch event with either an existing `issue_number` or a non-empty `task`. A new task payload creates an issue with the required label.

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

## Skills

#### Mermaid Diagrams

When the user asks to create, edit, or visualize a diagram, follow the
instructions in `.github/instructions/mermaid.instructions.md`.

<!-- mermaid-ai-skills:end -->
