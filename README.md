# dotfiles
My (shareable) dotfiles for various and sundry apps and systems, managed with [chezmoi](https://www.chezmoi.io/).

The repo is cloned to `~/.dotfiles` on most machines (anywhere works; `init --source` records the location in
`~/.config/chezmoi/chezmoi.toml`). chezmoi copies files into `$HOME` rather than symlinking them, so edits go through
the repo and `chezmoi apply`.

## Bootstrap a brand-new machine
Best-effort walkthrough from a factory-fresh machine to a working shell. The dotfiles themselves only *require* zsh,
git, curl and chezmoi; everything else they reference is picked up if present and skipped if not.

### What the dotfiles expect
| Need | Why | Without it |
|---|---|---|
| zsh, git, curl | login shell; `.zshrc` clones oh-my-zsh + plugins on first run | won't work |
| chezmoi | installs/updates the dotfiles | won't work |
| SSH key on GitHub (1Password agent on macOS) | `--ssh` clone, so you can push | use the read-only HTTPS clone |
| Homebrew | `.zshenv`/`.zprofile` load `brew shellenv` from `/opt/homebrew` or `/home/linuxbrew` | fine, you just install tools some other way |
| A [Nerd Font](https://www.nerdfonts.com/) in the terminal | starship prompt glyphs | prompt shows tofu boxes |
| starship, fzf, fd, bat, ripgrep, git-delta, uutils-coreutils | prompt, fzf-tab previews, `ls`/`rg`/`fd` aliases, `dircolors` | features quietly off, **except delta**: `.gitconfig` sets it as the pager, so `git diff`/`log` error without it |
| VS Code with `code` on PATH | `$EDITOR`, git editor/diff/merge tool | `$EDITOR` falls back to vim; git editor/mergetool calls fail |
| Git Credential Manager (work) | Azure Repos auth via `~/.gitconfig.local` | only needed on work machines |

### macOS
Order matters mostly because each step unlocks the next (Homebrew installs everything, 1Password holds the SSH key
for the clone). Run steps 1–5 in the same terminal, or redo the `export`/`eval` lines in a new one.

1. **Homebrew** (also installs the Xcode Command Line Tools, which brings git). Needs an admin account; on a managed
   work Mac, elevate first if IT requires it.
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
2. **Apps**: terminal, password manager, editor, and a Nerd Font (any; JetBrains Mono shown).
   ```sh
   brew install --cask 1password iterm2 visual-studio-code font-jetbrains-mono-nerd-font
   ```
   Then set the font in iTerm2 → Settings → Profiles → Text. Switching to iTerm2 now is fine, as long as you redo the
   `eval` line from step 1 there.
3. **1Password SSH agent**: sign in, then Settings → Developer → *Use the SSH agent*. Point this shell at it (the
   dotfiles do this automatically from then on) and check GitHub auth, which also accepts GitHub's host key:
   ```sh
   export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
   ssh -T git@github.com   # "Hi doubleyewdee! You've successfully authenticated..."
   ```
4. **CLI tools** the dotfiles use:
   ```sh
   brew install chezmoi starship fzf fd bat ripgrep git-delta uutils-coreutils neovim
   brew install --cask git-credential-manager   # work machines
   ```
   worktrunk (`wt`), if wanted: see [worktrunk.dev](https://worktrunk.dev).
5. **Dotfiles**: answer the *Work machine* prompt, then see [Layers](#layers) for `~/.gitconfig.local`.
   ```sh
   chezmoi init --apply --ssh --source ~/.dotfiles doubleyewdee
   ```
6. **Open a new terminal tab.** The first shell installs oh-my-zsh, zsh-syntax-highlighting and fzf-tab, then you're
   set. `chezmoi doctor` is handy if anything looks off.

Not covered by this repo (yet): iTerm2 preferences, Hammerspoon config, VS Code settings (use Settings Sync).

### Linux / WSL / remotes
Install `zsh git curl` from the distro (`sudo apt install zsh git curl` on Debian/Ubuntu) and `chsh -s $(which zsh)`,
then use the read-only one-liner in [Install on a new machine](#install-on-a-new-machine). Homebrew (linuxbrew) plus
the same `brew install` line as macOS step 4 gets the full toolset; distro packages also work, except that Debian's
`fzf` is too old for the `FZF_DEFAULT_OPTS` in `.zshenv` and its `fd`/`bat` are renamed `fdfind`/`batcat`.

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
     `~/.gitconfig.local`. They're the tail of that file, so:
     ```sh
     sed -n '/^\[credential/,$p' ~/OneDrive/tools/dotfiles/gitconfig >> ~/.gitconfig.local
     ```
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
