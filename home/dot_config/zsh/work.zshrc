# work-only interactive config, sourced from ~/.zshrc; only installed by chezmoi when the `work` flag is set

_k8sinfra_venv() {
  local examine_dir venv_path
  local switch_venv=0

  case "$PWD" in
    "$HOME"/src/work/.worktrees/k8sinfra.?*)
      examine_dir=${PWD#"$HOME/src/work/.worktrees/"}
      venv_path="$HOME/src/work/.worktrees/${examine_dir%%/*}/src/msftkube/.venv"
      switch_venv=1
      ;;
    *)
      if [[ "$TERM_PROGRAM" == "vscode" ]]; then
        # Outside worktrees, leave VS Code's environment alone.
        return
      fi

      if [[ -z "$VIRTUAL_ENV" ]]; then
        examine_dir=$PWD
      elif [[ "$1" == "init" ]]; then
        examine_dir=$VIRTUAL_ENV
      else
        return
      fi

      case "$examine_dir" in
        "$HOME"/src/work/*)
          venv_path="$HOME/src/work/k8sinfra/src/msftkube/.venv"
          ;;
      esac
      ;;
  esac

  if [[ -d $venv_path ]]; then
    if [[ "$VIRTUAL_ENV" != "$venv_path" && ( -z "$VIRTUAL_ENV" || "$switch_venv" == 1 ) ]]; then
      source "$venv_path/bin/activate" || return
    fi

    if [[ -f "$venv_path/pyvenv.cfg" && `grep 'uv' $venv_path/pyvenv.cfg` ]]; then
      alias pip='uv pip'
    fi
  fi

  if which msftkube > /dev/null; then
    alias mk=msftkube
    if (( $+commands[register-python-argcomplete] )); then
      eval "$(register-python-argcomplete msftkube)"
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _k8sinfra_venv
# run once to handle direct launches into a venv-eligible directory
_k8sinfra_venv init

# BEGIN Agency MANAGED BLOCK
if [[ -d "$HOME/.config/agency/CurrentVersion" && ":${PATH}:" != *":$HOME/.config/agency/CurrentVersion:"* ]]; then
    export PATH="$HOME/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK
