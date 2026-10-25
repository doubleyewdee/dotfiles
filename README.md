# dotfiles
My (shareable) dotfiles for various and sundry apps and systems, managed with [chezmoi](https://www.chezmoi.io/).

## Install
On a fresh machine (installs chezmoi to `./bin`, clones this repo to `~/.local/share/chezmoi`, and applies):
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply doubleyewdee
```

If chezmoi is already installed: `chezmoi init --apply doubleyewdee`.

`init` asks once whether this is a work machine; answer again later with `chezmoi init --prompt`, or preset it
non-interactively with `--promptBool "Work machine=true"`.

## Layers
1. **Base**: everything in `home/`, applied on every machine.
2. **Work** (only when the `work` flag is set): `~/.config/zsh/work.zshenv` and `work.zshrc`.
3. **Local** (not managed, per machine): `~/.zshenv.local`, `~/.zshrc.local`, and `~/.gitconfig.local` (credential
   helpers, etc.).

`~/.zshenv` and `~/.zshrc` source `~/.config/zsh/*.zshenv` / `*.zshrc` and then their `.local` file at the end. Since
`chezmoi apply` overwrites managed files, anything an installer wants to append to `~/.zshrc` belongs in
`~/.zshrc.local` instead.

## Day-to-day
- `chezmoi edit ~/.zshrc` to edit the source copy, `chezmoi apply` to write it to `$HOME`.
- `chezmoi diff` to preview what `apply` would change; `chezmoi re-add` to pull in edits made directly to `$HOME`.
- `chezmoi cd` to drop into the source repo to commit/push.

## Testing / Demo
Clone this repo, then `./run.sh` to build and run a Docker container with these dotfiles applied for the current user.
The repo is mounted into the container as chezmoi's source directory, so after editing on the host just run
`chezmoi apply` (and `exec zsh -l`) inside the container. Use `DOTFILES_WORK=true ./run.sh` to include the work layer.

## Contents
- `home/`: chezmoi source state (see `.chezmoiroot`). Files use chezmoi naming, e.g. `dot_zshrc` becomes `~/.zshrc`
  and `dot_config/` becomes `~/.config/`.
- `Dockerfile`: Dockerfile to build a test container with these dotfiles.
- `run.sh`: script to build and run the Docker container.
