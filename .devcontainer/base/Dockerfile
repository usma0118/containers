FROM mcr.microsoft.com/devcontainers/base:alpine-3.20

LABEL maintainer="usma0118"
LABEL org.opencontainers.image.title="devcontainer"
LABEL org.opencontainers.image.description="Docker container"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/.devcontainer/base"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/.devcontainer/base"

ENV PYTHONUNBUFFERED=1
ARG USERNAME=vscode
ENV USER=${USERNAME} \
    HOME=/home/${USERNAME}

# Core packages (only from stable repos; no edge to avoid breakage)
RUN set -euxo pipefail; \
  apk add --no-cache \
    zsh ca-certificates curl wget gettext sshpass \
    fzf jq git yq openssh-client \
    task \
    python3 py3-pip \
    direnv shellcheck \
    ansible \
    age helm kubectl sops

# Install pipx in an isolated venv (PEP 668-safe) and expose it on PATH
RUN set -euxo pipefail; \
  python3 -m venv /opt/pipx-venv; \
  /opt/pipx-venv/bin/python -m pip install --upgrade pip setuptools wheel; \
  /opt/pipx-venv/bin/python -m pip install pipx; \
  ln -sf /opt/pipx-venv/bin/pipx /usr/local/bin/pipx

# Install lsd from upstream musl release (not in Alpine 3.20)
ARG LSD_VERSION=1.1.5
RUN set -euxo pipefail; \
  arch="$(uname -m)"; \
  case "$arch" in \
    x86_64)  target="x86_64-unknown-linux-musl" ;; \
    aarch64) target="aarch64-unknown-linux-musl" ;; \
    *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac; \
  url="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd-v${LSD_VERSION}-${target}.tar.gz"; \
  tmpdir="$(mktemp -d)"; \
  curl -fsSL "$url" -o "$tmpdir/lsd.tgz"; \
  tar -xzf "$tmpdir/lsd.tgz" -C "$tmpdir"; \
  install -m 0755 "$tmpdir"/lsd*/lsd /usr/local/bin/lsd; \
  rm -rf "$tmpdir"
# Install hadolint from GitHub release (musl static build)
ARG HADOLINT_VERSION=2.12.0
RUN set -euxo pipefail; \
  arch="$(uname -m)"; \
  case "$arch" in \
    x86_64)  target="x86_64" ;; \
    aarch64) target="arm64" ;; \
    *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac; \
  url="https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${target}"; \
  curl -fsSL "$url" -o /usr/local/bin/hadolint; \
  chmod +x /usr/local/bin/hadolint

# Switch to non-root; user-scoped setup from here
USER ${USERNAME}

# Ensure pipx shims are on PATH for the user
ENV PIPX_BIN_DIR="${HOME}/.local/bin" \
    PATH="${PIPX_BIN_DIR}:${PATH}"

# Optional per-project venv (keep CLIs out of it)
RUN set -euxo pipefail; \
  python3 -m venv "${HOME}/.venv" || true
ENV VIRTUAL_ENV="${HOME}/.venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PIPX_BIN_DIR}:${PATH}"

# Base Python tooling in the project venv
RUN set -euxo pipefail; \
  if [ -x "${VIRTUAL_ENV}/bin/python" ]; then \
    python -m pip install --upgrade setuptools wheel; \
  fi

# Global CLI tools via pipx (installed into ~/.local/pipx envs; shims in ~/.local/bin)
RUN set -euxo pipefail; \
  pipx install pre-commit; \
  pipx install poetry; \
  pipx install ansible-lint

# direnv config (user scope)
RUN set -euxo pipefail; \
  mkdir -p "${HOME}/.config/direnv"; \
  printf '%s\n' \
    '[whitelist]' \
    'prefix = [ "/workspaces", "/home/vscode/.dotfiles" ]' \
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
RUN set -euxo pipefail; \
  { \
    echo 'export HISTFILE="$HOME/.history/.zsh_history"'; \
    echo 'setopt INC_APPEND_HISTORY SHARE_HISTORY'; \
    echo 'eval "$(direnv hook zsh)"'; \
  } >> "${HOME}/.zshrc"

# Oh-My-Zsh extras (assumes oh-my-zsh is installed by your dotfiles bootstrap)
RUN set -euxo pipefail; \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"; \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions     "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"; \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git          "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"; \
  curl -fsSL -o "${HOME}/.p10k.zsh" https://raw.githubusercontent.com/usma0118/dotfiles/HEAD/zshrc/themes/dev.p10k.zsh

# Dotfiles bootstrap (non-interactive; tolerate no-op)
RUN set -euxo pipefail; \
  git config --global --add safe.directory "${HOME}/.dotfiles"; \
  git clone --depth=1 https://github.com/usma0118/dotfiles "${HOME}/.dotfiles" || true; \
  sh -lc "cd '${HOME}/.dotfiles' && bash bootstrap.sh" || true

WORKDIR /workspaces
