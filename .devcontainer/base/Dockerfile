FROM mcr.microsoft.com/devcontainers/base:alpine-3.19

LABEL maintainer="usma0118"
LABEL org.opencontainers.image.title="Pythyon devcontainer"
LABEL org.opencontainers.image.description="Alpine dev container"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/.devcontainer/base"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/.devcontainer/base"

ENV PYTHONUNBUFFERED=1

ARG USERNAME=vscode
ENV USER=${USERNAME} \
    HOME=/home/${USERNAME}

# Core packages
RUN apk add --no-cache \
      zsh ca-certificates curl wget gettext sshpass \
      fzf jq git yq openssh-client \
      go-task \
      python3 py3-pip py3-venv \
      direnv shellcheck \
      ansible ansible-lint \
      py3-pipx \
  && apk add --no-cache \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
      age helm kubectl sops \
  && apk add --no-cache \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
      lsd

# Switch to non-root for user-scoped setup
USER ${USERNAME}

# Python project venv (keep lean; no global CLIs inside it)
RUN python3 -m venv "${HOME}/.venv"
ENV VIRTUAL_ENV="${HOME}/.venv"
# pipx installs shims into ~/.local/bin on Alpine
ENV PIPX_HOME="${HOME}/.local/pipx" \
    PIPX_BIN_DIR="${HOME}/.local/bin" \
    PATH="${VIRTUAL_ENV}/bin:${PIPX_BIN_DIR}:${PATH}"

# Base Python tooling in venv only
RUN python -m pip install --upgrade pip setuptools wheel

# Global CLIs via pipx (outside the venv)
RUN pipx install pre-commit \
 && pipx install poetry

# direnv config (user scope)
RUN mkdir -p "${HOME}/.config/direnv" \
 && printf '%s\n' \
    '[whitelist]' \
    'prefix = [ "/workspaces", "/home/vscode/.dotfiles" ]' \
    > "${HOME}/.config/direnv/direnv.toml"

# Ensure expected directories exist (and for oh-my-zsh custom tree)
RUN mkdir -p \
      "${HOME}/.vscode-server/extensions" \
      "${HOME}/.cache" \
      "${HOME}/.local" \
      "${HOME}/.history" \
      "${HOME}/.oh-my-zsh/custom/themes" \
      "${HOME}/.oh-my-zsh/custom/plugins"

# zsh configuration: history + direnv hook
RUN { \
      echo 'export HISTFILE="$HOME/.history/.zsh_history"'; \
      echo 'setopt INC_APPEND_HISTORY SHARE_HISTORY'; \
      echo 'eval "$(direnv hook zsh)"'; \
    } >> "${HOME}/.zshrc"

# Oh-My-Zsh extras (assumes oh-my-zsh is installed by your dotfiles bootstrap)
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
 && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions     "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
 && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git          "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" \
 && curl -sLo "${HOME}/.p10k.zsh" https://raw.githubusercontent.com/usma0118/dotfiles/HEAD/zshrc/themes/dev.p10k.zsh

# Dotfiles bootstrap (non-interactive)
RUN git config --global --add safe.directory "${HOME}/.dotfiles" \
 && git clone --depth=1 https://github.com/usma0118/dotfiles "${HOME}/.dotfiles" \
 && /bin/sh -c "cd '${HOME}/.dotfiles' && bash bootstrap.sh || true"

WORKDIR /workspaces


