#!/usr/bin/env sh
# usage: ./run.sh            # personal machine config
#        DOTFILES_WORK=true ./run.sh   # include the work-only layer
set -ex

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NEW_USER=$(whoami)

docker build --build-arg NEW_USER=$NEW_USER --tag wd-dotfiles:latest $SCRIPT_DIR
docker run --interactive --tty --rm --env DOTFILES_WORK="${DOTFILES_WORK:-false}" --volume "$SCRIPT_DIR:/home/$NEW_USER/src/dotfiles" wd-dotfiles:latest
