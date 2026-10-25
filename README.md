# dotfiles
My (shareable) dotfiles for various and sundry apps and systems, managed with [chezmoi](https://www.chezmoi.io/).

The repo is cloned to `~/.dotfiles` on most machines (anywhere works; `init --source` records the location in
`~/.config/chezmoi/chezmoi.toml`). chezmoi copies files into `$HOME` rather than symlinking them, so edits go through
the repo and `chezmoi apply`.

## Install on a new machine
Pick a flavor based on whether you'll be editing dotfiles from this machine:

```sh
# machines I edit on (gaming PC, work MacBook): clone over SSH so pushes work
brew install chezmoi
chezmoi init --apply --ssh --source ~/.dotfiles doubleyewdee

# remotes / throwaway boxes: read-only HTTPS clone, chezmoi installed to ~/.local/bin (no brew needed)
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply --source ~/.dotfiles doubleyewdee
```

`init` asks once whether this is a work machine (see [Layers](#layers)). Re-answer later with `chezmoi init --prompt`,
or preset it non-interactively with `--promptBool "Work machine=true"` (the key is the prompt text, not `work`).

On first interactive shell, `.zshrc` installs oh-my-zsh and its plugins itself, so just open a new terminal.

## Migrating a machine off OneDrive
Machines set up before this repo have `~/.zshrc` etc. as symlinks into `~/OneDrive/tools/dotfiles`. chezmoi replaces
those symlinks (files and directories) with real files and never writes through them, so OneDrive's copies are left
untouched for machines that haven't migrated yet.

1. **Install chezmoi**: `brew install chezmoi` (or the `get.chezmoi.io` line above).
2. **Move machine-specific config into local files** (see [Layers](#layers)), since the repo copies don't carry it:
   - Work machines: copy the work `[credential ...]` blocks (Azure Repos usernames/authority, the Git Credential
     Manager `helper` lines, `useHttpPath` for `dev.azure.com`) from `~/OneDrive/tools/dotfiles/gitconfig` into
     `~/.gitconfig.local`.
   - Anything an installer appended to this machine's shell files that isn't in the repo goes in `~/.zshrc.local` /
     `~/.zshenv.local`.
3. **Clone and preview** without applying:
   ```sh
   chezmoi init --ssh --source ~/.dotfiles doubleyewdee
   chezmoi diff      # every OneDrive symlink shows as replaced by a file; skim for content you'd lose
   ```
4. **Apply**: `chezmoi apply`, then `chezmoi verify` (silent and exit 0 means everything matches).
5. **Copy back state that lived inside symlinked directories**. Only managed files are created in the new real
   directories, e.g. `cp ~/OneDrive/tools/dotfiles/config/worktrunk/approvals.toml ~/.config/worktrunk/`.
6. **Clean up leftover OneDrive links** that aren't managed here (`.p10k.zsh`, `.muttrc`, `*-clocke-devbox`, ...):
   ```sh
   find ~ ~/.config -maxdepth 1 -lname '*OneDrive/tools/dotfiles*'
   ```
   On WSL, keep `~/OneDrive` / `~/winhome` themselves: `.zprofile` still links the PowerShell profile from there.
7. **Open a new terminal** (existing shells keep their old environment) and check that startup is clean.

Note that the OneDrive copies no longer get updates once a machine is migrated, so un-migrated machines drift. Once
every machine is migrated, `~/OneDrive/tools/dotfiles` can be retired.

## Day-to-day
On machines I edit on:
- `chezmoi update` first to pull and apply anything pushed from other machines.
- `chezmoi edit --apply ~/.zshrc` edits the repo copy and applies it; or edit files under `~/.dotfiles/home/` directly
  and run `chezmoi apply`. `chezmoi diff` previews what `apply` would change.
- If something edited `~/.zshrc` in place, `chezmoi diff` shows it: `chezmoi re-add` pulls it into the repo, or move it
  to `~/.zshrc.local`.
- Commit and push from the repo: `chezmoi cd` (opens a shell there), or `chezmoi git -- commit -am "..."` /
  `chezmoi git -- push`.

On remotes, just `chezmoi update` now and then. To make a read-only clone pushable later:
`chezmoi git -- remote set-url origin git@github.com:doubleyewdee/dotfiles.git`.

## Layers
1. **Base**: everything in `home/`, applied on every machine.
2. **Work** (only when the `work` flag is set): `~/.config/zsh/work.zshenv` and `work.zshrc`.
3. **Local** (not managed, per machine): `~/.zshenv.local`, `~/.zshrc.local`, and `~/.gitconfig.local` (credential
   helpers, etc.).

`~/.zshenv` and `~/.zshrc` source `~/.config/zsh/*.zshenv` / `*.zshrc` and then their `.local` file at the end. Since
`chezmoi apply` overwrites managed files, anything an installer wants to append to `~/.zshrc` belongs in
`~/.zshrc.local` instead.

## Testing / Demo
Clone this repo, then `./run.sh` to build and run a Docker container with these dotfiles applied for the current user.
The repo is mounted into the container as chezmoi's source directory, so after editing on the host just run
`chezmoi apply` (and `exec zsh -l`) inside the container. Use `DOTFILES_WORK=true ./run.sh` to include the work layer.

## Contents
- `home/`: chezmoi source state (see `.chezmoiroot`). Files use chezmoi naming, e.g. `dot_zshrc` becomes `~/.zshrc`
  and `dot_config/` becomes `~/.config/`. `.chezmoi.toml.tmpl` generates the machine config (work flag, source dir);
  `.chezmoiignore` drops the work layer when the flag is off.
- `Dockerfile`: Dockerfile to build a test container with these dotfiles.
- `run.sh`: script to build and run the Docker container.
