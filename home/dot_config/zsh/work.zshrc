# work-only interactive config, sourced from ~/.zshrc; only installed by chezmoi when the `work` flag is set

_k8sinfra_venv() {
  if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # in vscode, we may already be in a venv, so don't override that
    return
  fi

  if [[ "$VIRTUAL_ENV" == "" ]]; then
    examine_dir=$PWD
  # when launching in vscode (e.g.) we may already be in a venv
  elif [[ -n "$VIRTUAL_ENV" && "$1" == "init" ]]; then
    examine_dir=$VIRTUAL_ENV
  else
    return
  fi

  case $examine_dir in
    $HOME/src/work/k8sinfra2*)
      venv_path=~/src/work/k8sinfra2/src/msftkube/.venv
      ;;
    $HOME/src/work/k8sinfra3*)
      venv_path=~/src/work/k8sinfra3/src/msftkube/.venv
      ;;
    $HOME/src/work/*)
      venv_path=~/src/work/k8sinfra/src/msftkube/.venv
      ;;
    *)
      ;;
  esac

  if [[ -d $venv_path ]]; then
    if [[ -z "$VIRTUAL_ENV" ]]; then
      source $venv_path/bin/activate
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
