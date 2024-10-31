FROM mcr.microsoft.com/devcontainers/base:alpine-3.19

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.description="Docker container"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/.devcontainer/base"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/.devcontainer/base"
LABEL org.opencontainers.image.title="devcontainer"


ENV PYTHONUNBUFFERED 1
ARG USERNAME=vscode
ENV USER $USERNAME

RUN apk add --no-cache \
    zsh \
    ca-certificates curl wget gettext sshpass \
    fzf jq git openssh-client \
    go-task \
    python3 py3-pip py3-virtualenv\
    git direnv shellcheck\
    ansible ansible-lint &&\
    apk add --no-cache \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
        age helm kubectl sops &&\
    apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        lsd
RUN if [ -f /etc/bash.bashrc ]; then \
    echo -e 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc; \
    fi && \
    if [ -f /etc/zsh/zshrc ]; then \
        echo -e 'eval "$(direnv hook zsh)"' >> /etc/zsh/zshrc; \
    fi
USER $USERNAME

# Add direnv whitelist for the workspace directory
RUN mkdir -p /home/$USERNAME/.config/direnv &&\
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config &&\
tee /home/$USERNAME/.config/direnv/direnv.toml > /dev/null <<EOF
[whitelist]
prefix = [ "/workspaces", "/home/vscode/.dotfiles" ]
EOF

RUN virtualenv /home/$USERNAME/.venv &&\
    git config --global --add safe.directory /workspaces/dotfiles &&\
    git config --global --add safe.directory /home/$USERNAME/.dotfiles
ENV VIRTUAL_ENV /home/$USERNAME/.venv
ENV PATH $VIRTUAL_ENV:$PATH
RUN . $VIRTUAL_ENV/bin/activate && pip install --upgrade pip && pip install pre-commit
RUN mkdir /home/$USERNAME/.fonts \
# Download MesloLGS font files
&& curl -sLo /home/$USERNAME/.fonts/MesloLGS\ NF\ Regular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf \
&& curl -sLo /home/$USERNAME/.fonts/MesloLGS\ NF\ Bold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf \
&& curl -sLo /home/$USERNAME/.fonts/MesloLGS\ NF\ Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf \
&& curl -sLo /home/$USERNAME/.fonts/MesloLGS\ NF\ Bold\ Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf \
# Download zsh-syntax-highlighting
&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting --depth 1 \
# Download zsh-autosuggestions
&& git clone https://github.com/zsh-users/zsh-autosuggestions /home/$USERNAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions --depth 1 \
# Download powerlevel10k
&& git clone https://github.com/romkatv/powerlevel10k.git /home/$USERNAME/.oh-my-zsh/custom/themes/powerlevel10k --depth=1 \
# Download powerlevel10k config
&& curl -sLo /home/$USERNAME/.p10k.zsh https://raw.githubusercontent.com/usma0118/dotfiles/HEAD/zshrc/themes/dev.p10k.zsh

RUN mkdir -p /home/$USERNAME/.vscode-server/extensions \
        /home/$USERNAME/.cache \
        /home/$USERNAME/.local \
        /home/$USERNAME/.history \
    && chown -R $USERNAME \
        /home/$USERNAME/.vscode-server \
        /home/$USERNAME/.cache \
        /home/$USERNAME/.local \
        /home/$USERNAME/.history \
        /home/$USERNAME/.oh-my-zsh/custom/themes \
        /home/$USERNAME/.oh-my-zsh/custom/plugins &&\
        SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/home/$USERNAME/.history/.bash_history" >> "/home/$USERNAME/.bashrc" &&\
        echo "export PROMPT_COMMAND='history -a' && export HISTFILE=/home/$USERNAME/.history/.zsh_history" >> "/home/$USERNAME/.zsh_history"

RUN git clone https://github.com/usma0118/dotfiles /home/$USERNAME/.dotfiles --depth 1
WORKDIR /home/$USERNAME/.dotfiles
RUN . $VIRTUAL_ENV/bin/activate && bash bootstrap.sh
WORKDIR /workspaces
RUN echo "Pre-Loading zsh" && zsh -i -c "exit"