# work-only environment, sourced from ~/.zshenv; only installed by chezmoi when the `work` flag is set

if [[ "$CPUTYPE" == "arm64" ]]; then
  export DOCKER_DEFAULT_PLATFORM=linux/amd64
fi

if [[ -d $HOME/.ev2 ]]; then
  export PATH="$HOME/.ev2:$PATH"
fi

# trying this out to get the credential provider to work with Entra instead of ADO PATs? no idea if this should help
export NUGET_CREDENTIALPROVIDER_FORCE_CANSHOWDIALOG_TO="true"
