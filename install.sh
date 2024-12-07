#!/usr/bin/env bash

# Prevent system sleep while script is running
caffeinate -i -w $$ &

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

linkables=(
  # "zsh/.profile"
  # "zsh/.zshrc"
  # "zsh/.zshenv"
  # "zsh/.zprofile"
  # "zsh/.zsh_aliases"
  # "zsh/.zsh_functions"
  # "zsh/.zsh_prompt"
)

# Configuration home
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
  echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
  echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

backup() {
  BACKUP_DIR=$HOME/dotfiles-backup

  info "Creating backup directory at $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"

  info "Backing up linkable files..."

  for file in "${linkables[@]}"; do
    filename="$(basename "$file")"
    target="$HOME/$filename"
    if [ -f "$target" ]; then
      info "backing up $filename"
      cp "$target" "$BACKUP_DIR"
    else
      warning "$filename does not exist at this location or is a symlink"
    fi
  done

  for filename in "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.vimrc"; do
    if [ ! -L "$filename" ]; then
      info "backing up $filename"
      cp -rf "$filename" "$BACKUP_DIR"
    else
      warning "$filename does not exist at this location or is a symlink"
    fi
  done

  title "Exporting macOS settings..."
  $DOTFILES/macos/export-defaults.sh

}

cleanup_symlinks() {
  title "Cleaning up symlinks"
  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    if [ -L "$target" ]; then
      info "Cleaning up \"$target\""
      rm "$target"
    elif [ -e "$target" ]; then
      warning "Skipping \"$target\" because it is not a symlink"
    else
      warning "Skipping \"$target\" because it does not exist"
    fi
  done

  config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    if [ -L "$target" ]; then
      info "Cleaning up \"$target\""
      rm "$target"
    elif [ -e "$target" ]; then
      warning "Skipping \"$target\" because it is not a symlink"
    else
      warning "Skipping \"$target\" because it does not exist"
    fi
  done
}

setup_symlinks() {
  title "Creating symlinks"

  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    if [ -e "$target" ]; then
      info "~${target#"$HOME"} already exists... Skipping."
    else
      info "Creating symlink for $file"
      ln -s "$DOTFILES/$file" "$target"
    fi
  done

  echo
  info "installing to $config_home"
  if [ ! -d "$config_home" ]; then
    info "Creating $config_home"
    mkdir -p "$config_home"
  fi

  if [ ! -d "$data_home" ]; then
    info "Creating $data_home"
    mkdir -p "$data_home"
  fi

  config_files=$(find "$DOTFILES/config" -mindepth 1 -maxdepth 1 2>/dev/null)
  # echo "config_files: "
  # echo "$config_files"
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    if [ -e "$target" ]; then
      info "~${target#"$HOME"} already exists... Skipping."
    else
      info "Creating symlink for $config"
      ln -s "$config" "$target"
    fi
  done

  # symlink .zshenv into home directory to properly setup ZSH
  if [ ! -e "$HOME/.zshenv" ]; then
    info "Creating symlink for .zshenv"
    ln -s "$DOTFILES/config/zsh/.zshenv" "$HOME/.zshenv"
  else
    info "~/.zshenv already exists... Skipping."
  fi
}

copy() {
  if [ ! -d "$config_home" ]; then
    info "Creating $config_home"
    mkdir -p "$config_home"
  fi

  if [ ! -d "$data_home" ]; then
    info "Creating $data_home"
    mkdir -p "$data_home"
  fi
  config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    info "copying $config to $config_home/$config"
    cp -R "$config" "$target"
  done
}

setup_git() {
  title "Setting up Git"

  defaultName=$(git config user.name)
  defaultEmail=$(git config user.email)
  defaultGithub=$(git config github.user)

  read -rp "Name [$defaultName] " name
  read -rp "Email [$defaultEmail] " email
  read -rp "Github username [$defaultGithub] " github

  git config -f ~/.gitconfig-local user.name "${name:-$defaultName}"
  git config -f ~/.gitconfig-local user.email "${email:-$defaultEmail}"
  git config -f ~/.gitconfig-local github.user "${github:-$defaultGithub}"

  if [[ "$(uname)" == "Darwin" ]]; then
    git config --global credential.helper "osxkeychain"
  else
    read -rn 1 -p "Save user and password to an unencrypted file to avoid writing? [y/N] " save
    if [[ $save =~ ^([Yy])$ ]]; then
      git config --global credential.helper "store"
    else
      git config --global credential.helper "cache --timeout 3600"
    fi
  fi
}

setup_homebrew() {
  title "Setting up Homebrew"

  if test ! "$(command -v brew)"; then
    info "Homebrew is not installed."
    echo "Download installer from https://github.com/Homebrew/brew/releases/"
    exit 1
  fi

  if [ "$(uname)" == "Linux" ]; then
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
  fi

  # install brew dependencies from Brewfile
  brew bundle

  # install fzf
  echo
  info "Installing fzf"
  "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
}

setup_shell() {
  title "Configuring shell"

  [[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"
  if ! grep "$zsh_path" /etc/shells; then
    info "adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    info "default shell changed to $zsh_path"
  fi
}

function setup_terminfo() {
  title "Configuring terminfo"

  info "adding tmux.terminfo"
  tic -x "$DOTFILES/resources/tmux.terminfo"

  info "adding xterm-256color-italic.terminfo"
  tic -x "$DOTFILES/resources/xterm-256color-italic.terminfo"
}

setup_macos() {
  title "Configuring macos"
  if [[ "$(uname)" == "Darwin" ]]; then

    info "Restoring previously backed up defaults from $DOTFILES/macos/defaults.zip"
    $DOTFILES/macos/import-defaults.sh $DOTFILES/macos/defaults.zip

    info "Establishing settings defined in $DOTFILES/macos/macos-defaults.sh"
    $DOTFILES/macos/macos-defaults.sh

    info "Kill affected applications"

    for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
  else
    warning "macOS not detected. Skipping."
  fi
}

backup_spell() {
  title "Backing up macos spellcheck dictionary"
  if [[ "$(uname)" == "Darwin" ]]; then

    target="$HOME/Library/Group Containers/group.com.apple.AppleSpell/Library/Spelling/"

    BACKUP_DIR=$HOME/.config/dotfiles/macos/Spelling/

    cp -pR "$target" "$BACKUP_DIR"

    info "Spelling dictionary backed up to $BACKUP_DIR"
  else
    warning "macOS not detected. Skipping."
  fi
}

setup_spell() {
  title "Restoring macos spellcheck dictionary"
  if [[ "$(uname)" == "Darwin" ]]; then

    target="$HOME/Library/Group Containers/group.com.apple.AppleSpell/Library/Spelling/"

    BACKUP_DIR=$HOME/.config/dotfiles/macos/Spelling/

    cp -pR  "$BACKUP_DIR" "$target"

    info "Spelling dictionary restored to $target"
  else
    warning "macOS not detected. Skipping."
  fi
}

backup_spam() {
  title "Backing up SpamSieve corpus"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/SpamSieve/"
    target2="$HOME/Library/Preferences/com.c-command.SpamSieve.plist"

    BACKUP_DIR1="$HOME/.config/dotfiles/macos/spam/SpamSieve/"
    BACKUP_DIR2="$HOME/.config/dotfiles/macos/spam/"

    cp -pR "$target1" "$BACKUP_DIR1"
    cp -pR "$target2" "$BACKUP_DIR2"

    info "SpamSieve corpus backed up to $BACKUP_DIR1"
    info "SpamSieve settings backed up to $BACKUP_DIR2"
  else
    warning "macOS not detected. Skipping."
  fi
}

setup_spam() {
  title "Restoring SpamSieve corpus"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/SpamSieve/"
    target2="$HOME/Library/Preferences/"

    BACKUP_DIR1="$HOME/.config/dotfiles/macos/spam/SpamSieve/"
    BACKUP_DIR2="$HOME/.config/dotfiles/macos/spam/com.c-command.SpamSieve.plist"

    cp -pR "$BACKUP_DIR1" "$target1"
    cp -pR "$BACKUP_DIR2" "$target2"

    info "SpamSieve corpus restored to $target1"
    info "SpamSieve settings restored to $target2"
  else
    warning "macOS not detected. Skipping."
  fi
}

backup_bbedit() {
  title "Backing up BBEdit settings"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/BBEdit/"
    target2="$HOME/Library/Containers/com.barebones.bbedit/Data/Saved Application State.appstate"

    BACKUP_DIR1="$HOME/.config/dotfiles/bbedit/BBEdit/"
    BACKUP_DIR2="$HOME/.config/dotfiles/bbedit/"

    cp -pR "$target1" "$BACKUP_DIR1"
    cp -pR "$target2" "$BACKUP_DIR2"

    info "BBEdit configuration backed up to $BACKUP_DIR1"
    info "BBedit settings backed up to $BACKUP_DIR2"
  else
    warning "macOS not detected. Skipping."
  fi
}

setup_bbedit() {
  title "Restoring BBEdit settings"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/BBEdit/"
    target2="$HOME/Library/Containers/com.barebones.bbedit/Data/"

    BACKUP_DIR1="$HOME/.config/dotfiles/bbedit/BBEdit/"
    BACKUP_DIR2="$HOME/.config/dotfiles/bbedit/Saved Application State.appstate"

    cp -pR "$BACKUP_DIR1" "$target1"
    cp -pR "$BACKUP_DIR2" "$target2"

    info "BBEdit configuration restored from $BACKUP_DIR1"
    info "BBedit settings restored from $BACKUP_DIR2"
  else
    warning "macOS not detected. Skipping."
  fi
}

backup_pathfinder() {
  title "Backing up PathFinder settings"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/Path Finder/"
    target2="$HOME/Library/Preferences/com.cocoatech.PathFinder.plist"

    BACKUP_DIR1="$HOME/.config/dotfiles/pathfinder/Path Finder/"
    BACKUP_DIR2="$HOME/.config/dotfiles/pathfinder/"

    cp -pR "$target1" "$BACKUP_DIR1"
    cp -pR "$target2" "$BACKUP_DIR2"

    info "Path Finder configuration backed up to $BACKUP_DIR1"
    info "Path Finder settings backed up to $BACKUP_DIR2"
  else
    warning "macOS not detected. Skipping."
  fi
}

setup_pathfinder() {
  title "Restoring PathFinder settings"
  if [[ "$(uname)" == "Darwin" ]]; then

    target1="$HOME/Library/Application Support/Path Finder/"
    target2="$HOME/Library/Preferences/"

    BACKUP_DIR1="$HOME/.config/dotfiles/pathfinder/Path Finder/"
    BACKUP_DIR2="$HOME/.config/dotfiles/pathfinder/com.cocoatech.PathFinder.plist"

    cp -pR "$BACKUP_DIR1" "$target1"
    cp -pR "$BACKUP_DIR2" "$target2"

    info "Path Finder configuration restored up to $BACKUP_DIR1"
    info "Path Finder settings restored up to $BACKUP_DIR2"
  else
    warning "macOS not detected. Skipping."
  fi
}

setup_rust() {
  title "Configuring rust toolchain"
  read -p "This may take 30 minutes or more. Continue? (y/n) " yn
  case $yn in
    [yY]* )

    rustup-init

    echo
    title "Installing rust packages"
    source "$HOME/.cargo/env"
    cat $DOTFILES/rust/cargo_packages.txt | xargs cargo install
    ;;

    [nN]* ) echo "Exiting..."; exit;;
    * ) echo "You must answer yes or no.";;
  esac

}

case "$1" in
backup)
  backup
  ;;
clean)
  cleanup_symlinks
  ;;
link)
  setup_symlinks
  ;;
copy)
  copy
  ;;
git)
  setup_git
  ;;
homebrew)
  setup_homebrew
  ;;
shell)
  setup_shell
  ;;
terminfo)
  setup_terminfo
  ;;
macos)
  setup_macos
  ;;
spell)
  setup_spell
  ;;
backup_spell)
  backup_spell
  ;;
spam)
  setup_spam
  ;;
backup_spam)
  backup_spam
  ;;
bbedit)
  setup_bbedit
  ;;
backup_bbedit)
  backup_bbedit
  ;;
pathfinder)
  setup_pathfinder
  ;;
backup_pathfinder)
  backup_pathfinder
  ;;
rust)
  setup_rust
  ;;
all)
  setup_symlinks
  setup_terminfo
  setup_homebrew
  setup_shell
  setup_git
  setup_macos
  ;;
apps)
  setup_spell
  setup_spam
  setup_bbedit
  setup_pathfinder
  setup_rust
  ;;
*)
  title "Usage: $(basename "$0") {backup|clean|link|copy|git|homebrew|shell|terminfo|macos|all}"
  echo "  backup            - backup existing symlinks and macos settings"
  echo "  clean             - remove existing symlinks"
  echo "  link              - create symlinks"
  echo "  copy              - copy config files"
  echo "  git               - setup git"
  echo "  homebrew          - setup homebrew"
  echo "  shell             - setup shell"
  echo "  terminfo          - setup terminfo"
  echo "  macos             - setup macos"
  echo "  all               - setup everything"
  echo ""
  info "Applications: $(basename "$0") {spell|spam|bbedit|pathfinder|rust|apps}\n"
  echo "  spell             - restore macOS spellcheck dictionary"
  echo "  backup_spell      - backup macOS spellcheck dictionary"
  echo "  spam              - restore SpamSieve dictionary"
  echo "  backup_spam       - backup SpamSieve dictionary"
  echo "  bbedit            - restore BBEdit settings"
  echo "  backup_bbedit     - backup BBEdit settings"
  echo "  pathfinder        - restore PathFinder settings"
  echo "  backup_pathfinder - backup PathFinder settings"
  echo "  rust              - setup rust toolchain"
  echo "  apps              - setup/restore all applications"

  exit 1
  ;;
esac

echo
success "Done."
