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

# Optional per-project venv (keep CLIs out of it)
RUN apk update --no-cache && apk add --no-cache bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Core packages (only from stable repos; no edge to avoid breakage)
RUN set -euxo pipefail; \
  apk add --no-cache \
    zsh ca-certificates curl wget gettext sshpass shellcheck \
    fzf jq git yq openssh-client \
    python3 py3-pip poetry \
    direnv \
    task \
    tree \
    age sops \
    ansible

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
    pre-commit setuptools wheel ansible-lint; \
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

WORKDIR /workspaces
