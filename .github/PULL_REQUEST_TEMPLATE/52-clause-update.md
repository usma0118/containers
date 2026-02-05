This PR applies requested changes from issue #52:

- Add `nodejs` to the base devcontainer
- Make global `@anthropic-ai/claude-code` `npm` installation conditional when `npm` is available
- Install `pytest` and `pytest-mock` into the project virtualenv
- Fix hadolint warnings by escaping shell variables when writing to `.zshrc`

No changes are made to `cryfs` or `encfs`; only the `.devcontainer/base` image is modified.

Notes: `libnotify`/`notify-send` was omitted because it caused apk failures on this Alpine base; we can add it behind a conditional or via a different package name if you want.

Refs: #52