# Multi-stage Dockerfile for testing dotfiles

# Stage 1: Base Debian with package repositories
FROM debian:13 AS base
ARG NEW_USER="wd"

# Update package lists and install base dependencies
RUN apt update && apt install -y \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Package installation layer
FROM base AS packages
ARG NEW_USER

# Install apt packages
RUN apt update && apt install -y \
    zsh \
    vim \
    tmux \
    htop \
    tree \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/zsh -G sudo $NEW_USER && \
    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Homebrew
USER ${NEW_USER}
WORKDIR /home/${NEW_USER}
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

RUN brew install \
    bat \
    chezmoi \
    fd \
    fzf \
    git-delta \
    ripgrep \
    starship \
    uutils-coreutils

# Stage 3: User setup and dotfiles
FROM packages AS final
USER ${NEW_USER}

# run.sh mounts the repo at ~/src/dotfiles; point chezmoi's default source dir at it so `chezmoi apply` inside the
# container picks up edits made on the host without a rebuild
RUN mkdir -p /home/${NEW_USER}/.local/share && \
    ln -s /home/${NEW_USER}/src/dotfiles /home/${NEW_USER}/.local/share/chezmoi
# DOTFILES_WORK=true (see run.sh) answers chezmoi's `work` prompt to test the work-only layer
CMD ["/bin/sh", "-c", "chezmoi init --apply --promptBool \"Work machine=${DOTFILES_WORK:-false}\" && exec /bin/zsh --login"]