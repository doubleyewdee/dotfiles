# dotfiles
My (shareable) dotfiles for various and sundry apps and systems, managed with [chezmoi](https://www.chezmoi.io/).

## Install
On a fresh machine (installs chezmoi to `./bin`, clones this repo to `~/.local/share/chezmoi`, and applies):
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply doubleyewdee
```

If chezmoi is already installed: `chezmoi init --apply doubleyewdee`.

Machine- or work-specific git settings (credential helpers, etc.) go in `~/.gitconfig.local`, which is included by
`~/.gitconfig` but not managed here.

## Day-to-day
- `chezmoi edit ~/.zshrc` to edit the source copy, `chezmoi apply` to write it to `$HOME`.
- `chezmoi diff` to preview what `apply` would change; `chezmoi re-add` to pull in edits made directly to `$HOME`.
- `chezmoi cd` to drop into the source repo to commit/push.

## Testing / Demo
Clone this repo, then `./run.sh` to build and run a Docker container with these dotfiles applied for the current user.
The repo is mounted into the container as chezmoi's source directory, so after editing on the host just run
`chezmoi apply` (and `exec zsh -l`) inside the container.

## Contents
- `home/`: chezmoi source state (see `.chezmoiroot`). Files use chezmoi naming, e.g. `dot_zshrc` becomes `~/.zshrc`
  and `dot_config/` becomes `~/.config/`.
- `Dockerfile`: Dockerfile to build a test container with these dotfiles.
- `run.sh`: script to build and run the Docker container.
