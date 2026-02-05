FROM mcr.microsoft.com/devcontainers/base:alpine-3.22

LABEL maintainer="usma0118"
LABEL org.opencontainers.image.title="devcontainer"
LABEL org.opencontainers.image.description="Development dev container"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/.devcontainer/base"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/.devcontainer/base"

# --- keep ARG earlier ---
ARG USERNAME=vscode

# Split ENVs to satisfy DL3044
ENV USER=${USERNAME}
ENV HOME=/home/${USERNAME}
ENV PYTHONUNBUFFERED=1
ENV DEVCONTAINER=true
ENV EDITOR=nano
ENV VISUAL=nano

# Optional per-project venv (keep CLIs out of it)
RUN apk update --no-cache && apk add --no-cache bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Core packages (only from stable repos; no edge to avoid breakage)
RUN set -euxo pipefail; \
  apk add --no-cache \
    zsh ca-certificates curl wget gettext sshpass shellcheck \
    fzf jq git yq openssh-client \
    python3 py3-pip poetry \
    nodejs \
    direnv \
    task \
    tree \
    age sops \
    ansible \
    iptables iproute2 ipset bind-tools

# Install lsd from upstream musl release (not in Alpine 3.20)
ARG LSD_VERSION=1.1.5
ARG TARGETARCH   # provided by Docker buildx
RUN set -euxo pipefail; \
  case "${TARGETARCH:-$(uname -m)}" in \
    amd64|x86_64)  target="x86_64-unknown-linux-musl" ;; \
    arm64|aarch64) target="aarch64-unknown-linux-musl" ;; \
    *) echo "Unsupported arch: ${TARGETARCH:-$(uname -m)}" >&2; exit 1 ;; \
  esac; \
  url="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd-v${LSD_VERSION}-${target}.tar.gz"; \
  tmpdir="$(mktemp -d)"; \
  curl -fsSL "$url" -o "$tmpdir/lsd.tgz"; \
  tar -xzf "$tmpdir/lsd.tgz" -C "$tmpdir"; \
  install -m 0755 "$tmpdir"/lsd*/lsd /usr/local/bin/lsd; \
  rm -rf "$tmpdir"

ARG CLAUDE_CODE_VERSION=latest
RUN if command -v npm >/dev/null 2>&1; then \
      npm install -g @anthropic-ai/claude-code@"${CLAUDE_CODE_VERSION}"; \
    else \
      echo "npm not available; skipping global @anthropic-ai/claude-code install"; \
    fi

# Install GitHub CLI from releases when not available in apk
ARG GH_VERSION=2.45.0
RUN set -euxo pipefail; \
  case "${TARGETARCH:-$(uname -m)}" in \
    amd64|x86_64) gh_arch="amd64" ;; \
    arm64|aarch64) gh_arch="arm64" ;; \
    *) echo "Unsupported arch: ${TARGETARCH:-$(uname -m)}" >&2; exit 0 ;; \
  esac; \
  if ! command -v gh >/dev/null 2>&1; then \
    tmpdir="$(mktemp -d)"; \
    url="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${gh_arch}.tar.gz"; \
    echo "Installing gh from ${url}"; \
    if curl -fsSL "$url" -o "$tmpdir/gh.tgz"; then \
      tar -xzf "$tmpdir/gh.tgz" -C "$tmpdir"; \
      install -m 0755 "$tmpdir"/gh_${GH_VERSION}_linux_${gh_arch}/bin/gh /usr/local/bin/gh || true; \
      rm -rf "$tmpdir"; \
    else \
      echo "Failed to download gh release; gh will not be available"; \
    fi; \
  fi

# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall

# Switch to non-root; user-scoped setup from here
USER ${USERNAME}

# Optional per-project venv (keep CLIs out of it)
RUN set -euxo pipefail; \
  python3 -m venv "${HOME}/.venv" || true

ENV VIRTUAL_ENV=${HOME}/.venv
ENV PATH=${VIRTUAL_ENV}/bin:${PATH}

# Base Python tooling in the project venv
RUN set -euxo pipefail; \
  if [ -x "${VIRTUAL_ENV}/bin/python" ]; then \
    ${VIRTUAL_ENV}/bin/python -m pip install --no-cache-dir --upgrade pip poetry \
    pre-commit setuptools wheel ansible-lint pytest pytest-mock; \
  fi
RUN pre-commit install --install-hooks || true
# direnv config (user scope)
RUN set -euxo pipefail; \
  mkdir -p "${HOME}/.config/direnv"; \
  printf '%s\n' \
    '[whitelist]' \
    'prefix = [ "/workspaces" ]' \
    > "${HOME}/.config/direnv/direnv.toml"

# Expected dirs (and oh-my-zsh custom tree)
RUN set -euxo pipefail; \
  mkdir -p \
    "${HOME}/.vscode-server/extensions" \
    "${HOME}/.cache" \
    "${HOME}/.local" \
    "${HOME}/.history" \
    "${HOME}/.oh-my-zsh/custom/themes" \
    "${HOME}/.oh-my-zsh/custom/plugins"

# zsh: history + direnv hook
# shellcheck disable=SC2016
# hadolint ignore=SC2016
RUN set -euxo pipefail; \
  { \
    echo "export HISTFILE=\"\$HOME/.history/.zsh_history\""; \
    echo "setopt INC_APPEND_HISTORY SHARE_HISTORY"; \
    echo "eval \"\$(direnv hook zsh)\""; \
  } >> "${HOME}/.zshrc"

# Oh-My-Zsh extras (assumes oh-my-zsh is installed by your dotfiles bootstrap)
RUN set -euxo pipefail; \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"; \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions     "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"; \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git          "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"; \
  curl -fsSL -o "${HOME}/.p10k.zsh" https://raw.githubusercontent.com/usma0118/dotfiles/HEAD/zshrc/themes/dev.p10k.zsh

# Add GitHub CLI zsh completions (if gh is available in the image)
RUN set -euxo pipefail; \
  if command -v gh >/dev/null 2>&1; then \
    mkdir -p "${HOME}/.oh-my-zsh/custom/plugins/gh"; \
    gh completion -s zsh > "${HOME}/.oh-my-zsh/custom/plugins/gh/_gh" || true; \
    echo "fpath+=(\"\$HOME/.oh-my-zsh/custom/plugins/gh\")" >> "${HOME}/.zshrc"; \
  fi

WORKDIR /workspaces
