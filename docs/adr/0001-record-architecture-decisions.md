# ADR 0001 — Record architecture decisions

Date: 2026-02-01

Status: Proposed

## Context

This repository uses Copilot Agents and GitHub Actions to automate issue intake, branch creation, and PRs. We need a place to record architectural decisions, rationale, and consequences so future contributors understand why choices were made.

## Decision

We will store Architecture Decision Records (ADRs) in the `docs/adr/` directory. Each ADR will be a Markdown file named with a zero-padded sequence number followed by a short slug, for example `0001-record-architecture-decisions.md`.

## Consequences

- ADRs are versioned with the repository for traceability.
- Contributors should create a new ADR for non-trivial design decisions.

## Template / How to create a new ADR

1. Copy this file and increment the number (e.g., `0002-my-decision.md`).
2. Update `Date`, `Status` (Proposed|Accepted|Deprecated), `Context`, `Decision`, and `Consequences` sections.

---

References:

- Runbook: `.github/workflows/copilot-agents.yml`
