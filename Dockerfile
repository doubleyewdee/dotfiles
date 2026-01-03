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
    ripgrep \
    fd-find \
    bat \
    fzf \
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
    git-delta \
    starship \
    uutils-coreutils

# Stage 3: User setup and dotfiles
FROM packages AS final
USER ${NEW_USER}

# Copy dotfiles from the repository
# Note: Add your actual dotfiles as you create them
COPY --chown=${NEW_USER}:${NEW_USER} src /home/${NEW_USER}/dotfiles/
# just symlinking the three zsh dotfiles should be enough to make everything else get setup via those dotfiles
RUN ln -s /home/${NEW_USER}/dotfiles/zshenv /home/${NEW_USER}/.zshenv
RUN ln -s /home/${NEW_USER}/dotfiles/zshrc /home/${NEW_USER}/.zshrc
RUN ln -s /home/${NEW_USER}/dotfiles/zprofile /home/${NEW_USER}/.zprofile
CMD ["/bin/zsh", "--login"]