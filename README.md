# Dotfiles

###############################################
TODO list

1. Execute Dotfiles to install apps and some settings
2. Configure remaining macOS System Settings per Sonoma_Settings.txt
3. Configure shell environment [/etc/fstab, .ssh .profile, fzf, fnm, wezterm, starship, aerospace]
4. Configure applications\
   4.1. 1Password login and authorization \
   4.2. TorGuard login - Glen \
   4.3. Warp login - Janis \
   4.4. Firefox login - see ~/.config/setup/Browser-extension-list.txt \
   4.5. Firefox and Safari Install extensions see ~/.config/setup browser-extension-list.txt \
   4.6. Setup Shortcat - Hot key CMD-Space \
   -- Sys Settings > Spotlight > Keyboard shortcuts > Keyboard Shortcuts > Spotlight > Show Spotlight search > Ctrl-Space\
   4.7. brew info sqlite \
   4.8. brew info mysql \
   4.9. brew info fzf \
   4.10. brew info pkgx \
   4.11. Default folder X install license key \
   4.12. Dropbox login \
   4.13. Beyond compare install license key \
   4.14. SoftRAID install license key\
   4.15. SuperDuper configure scheduled backups to G-SON-SD \
   4.15. Time Machine setup backup to G-SON-TM \
   4.16. Setup Flux \
   4.17. VS Code sign in to github, snyk, phind, settings, codium, docker hub  \
   4.18. Setup CheatSheet \
   4.19. Open all "Third Party Apps" (see Brewfile) and configure as needed

###############################################
### Adapted from https://mths.be/macos, https://github.com/nicknisi/dotfiles and
### https://github.com/ooloth/dotfiles
### Thanks guys! 💖

## Initial setup

> ## Note
> This utility is designed to run on a fresh macOS install:
> Things you will need:
> - Internet connection
> - Administrator user name and password
> - - Password will be prompted several times throughout execution
> - Apple ID and password for the administrator account (or create a new ID)
> - - Items from App Store must be previously purchased or shared. see Brewfile > mas
> - - Terminal used to run this script must have full disk access
> - ssh key for GitHub account
> - Passphrase for Github ssh key
>
> ## Procedure
>
> Transfer or Reset
> - Empty Trash (reset does not!)
> - System Settings > Transfer or Reset > Erase All Content and Settings

> Create an admin user that will execute this utility
> Set Machine Name (updates User and Hostname) - System Settings > General > About
> Set Full Disk Access for terminal - System Settings > Privacy & Security > Full Disk Access > +
> Login with an appropriate Apple ID for Mac App Store support
> Install Xcode from the App Store
>
> Open terminal to run the remaining commands

```bash
hostname # change as desired with sudo hostname {new name}
xcode-select --install
git --version #(agree to Apple terms)

ssh git@github.com # A github ssh key must be installed

git clone git@github.com:gihrig/dotfiles.git ~/.config/dotfiles && cd ~/.config/dotfiles

./install.sh # likely run ./install.sh all
```

> [!Note]
>
> This dotfiles configuration is set up in such a way that it _shouldn't_ matter
> where the repo exists on your system.

The script, `install.sh` is the one-stop for all things setup, backup, and
installation.

```bash
> ./install.sh help

Usage: install.sh {backup|link|homebrew|shell|terminfo|macos|all}
```

See the end of this file for further details

### `all`
Generally, this is the command to use for a new installation

```bash
./install.sh all
```

the `all` command runs all of the installation tasks described below, in full, with
the exception of the `backup` script. You must run that one manually.

### `backup`

```bash
./install.sh backup
```

Create a backup of the current dotfiles (if any) into `~/.dotfiles-backup/`.
This will scan for the existence of every file that is to be symlinked and will
move them over to the backup directory. It will also do the same for vim setups,
moving some files in the
[XDG base directory](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html),
(`~/.config`).

- `~/.config/nvim/` - The home of [neovim](https://neovim.io/) configuration
- `~/.vim/` - The home of vim configuration
- `~/.vimrc` - The main init file for vim

### `link`

```bash
./install.sh link
```

The `link` command will create
[symbolic links](https://en.wikipedia.org/wiki/Symbolic_link) from the dotfiles
directory into the `$HOME` directory, allowing for all of the configuration to
_act_ as if it were there without being there, making it easier to maintain the
dotfiles in isolation.

### `homebrew`

```bash
./install.sh homebrew
```

The `homebrew` command sets up [homebrew](https://brew.sh/) by downloading and
running the homebrew installers script. Homebrew is a macOS package manager, but
it also work on linux via Linuxbrew. If the script detects that you're
installing the dotfiles on linux, it will use that instead. For consistency
between operating systems, linuxbrew is set up but you may want to consider an
alternate package manager for your particular system.

Once homebrew is installed, it executes the `brew bundle` command which will
install the packages listed in the [Brewfile](./Brewfile).

### `shell`

```bash
./install.sh shell
```

The `shell` command sets up the recommended shell configuration for the dotfiles
setup. Specifically, it sets the shell to [zsh](https://www.zsh.org/) using the
`chsh` command.

### `terminfo`

```bash
./install.sh terminfo
```

This command uses `tic` to set up the terminfo, specifically to allow for
_italics_ within the terminal. If you don't care about that, you can ignore this
command.

### `macos`

```bash
./install.sh macos
```

The `macos` command sets up macOS-specific configurations using the
`defaults write` commands to change default values for macOS.

- Finder: show all filename extensions
- show hidden files by default
- only use UTF-8 in Terminal.app
- expand save dialog by default
- Enable full keyboard access for all controls (e.g. enable Tab in modal
  dialogs)
- Enable subpixel font rendering on non-Apple LCDs
- Use current directory as default search scope in Finder
- Show Path bar in Finder
- Show Status bar in Finder
- Disable press-and-hold for keys in favor of key repeat
- Set a blazingly fast keyboard repeat rate
- Set a shorter Delay until key repeat
- Enable tap to click (Trackpad)
- Enable Safari’s debug menu

## ZSH Configuration

The prompt for ZSH is configured in the `zsh/zshrc` file and performs the
following operations.

- Sets `EDITOR` to `nvim`
- Loads any `~/.terminfo` setup
- Sets `CODE_DIR` to `~/Developer`. This can be changed to the location you use
  to put your git checkouts, and enables fast `cd`-ing into it via the `c`
  command
- Recursively searches the `$DOTFILES/zsh` directory for any `.zsh` files and
  sources them
- Sources a `~/.localrc`, if available for configuration that is
  machine-specific and/or should not ever be checked into git
- Adds `~/bin` and `$DOTFILES/bin` to the `PATH`

### ZSH plugins

There are a number of plugins in use for ZSH, and they are installed and
maintained separately via the `zfetch` command. `zfetch` is a custom plugin
manager available [here](./zsh/functions/zfetch). The plugins that are used are
listed in the `.zshrc` and include

- [zsh-async](https://github.com/mafredri/zsh-async)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-npm-scripts-autocomplete](https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)

Additional plugins can be added to the `~/.zshrc`, or to `~/.localrc` if you
want them to stay out of git.

```bash
# Add a line like this and the plugin will automatically be downloaded and sourced
zfetch nicknisi/work-scripts
```

### Prompt

Aloxaf/fzf-tab The prompt is meant to be simple while still providing a lot of
information to the user, particularly about the status of the git project, if
the PWD is a git project. This prompt sets `precmd`, `PROMPT` and `RPROMPT`. The
`precmd` shows the current working directory in it and the `RPROMPT` shows the
git and suspended jobs info. The main symbol used on the actual prompt line is
`❯`.

The prompt attempts to speed up certain information lookups by allowing for the
prompt itself to be asynchronously rewritten as data comes in. This prevents the
prompt from feeling sluggish when, for example, the user is in a large git repo
and the git prompt commands take a considerable amount of time.

It does this by writing the actual text that will be displayed in the prompt to
a temp file, which is then used to update the prompt information when a signal
is trapped.

#### Git Prompt

The git info shown on the `RPROMPT` displays the current branch name, along with
the following symbols.

- `+` - New files were added
- `!` - Existing files were modified
- `?` - Untracked files exist that are not ignored
- `»` - Current changes include file renaming
- `✘` - An existing tracked file has been deleted
- `$` - There are currently stashed files
- `=` - There are unmerged files
- `⇡` - Branch is ahead of the remote (indicating a push is needed)
- `⇣` - Branch is behind the remote (indicating a pull is needed)
- `⇕` - The branches have diverged (indicating history has changed and maybe a
  force-push is needed)
- `✔` - The current working directory is clean

#### Jobs Prompt

The prompt will also display a `✱` character in the `RPROMPT` indicating that
there is a suspended job that exists in the background. This is helpful in
keeping track of putting vim in the background by pressing CTRL-Z.

#### Node Prompt

If a `package.json` file or a `node_modules` directory exists in the current
working directory, display the node symbol, along with the current version of
Node. This is useful information when switching between projects that depend on
different versions of Node.

## Neovim setup

> [!Note]
>
> This is no longer a vim setup. The configuration has been moved to be
> Neovim-specific and (mostly) written in [Lua](https://www.lua.org/). `vim` is
> also set up as an alias to `nvim` to help with muscle memory.

The simplest way to install Neovim is to install it from homebrew.

```bash
brew install neovim
```

However, it was likely installed already if you ran the `./install.sh brew`
command provided in the dotfiles.

All of the configuration for Neovim starts at `config/nvim/init.lua`, which is
symlinked into the `~/.config/nvim` directory.

> [!Warning]
>
> The first time you run `nvim` with this configuration, it will likely have a
> lot of errors. This is because it is dependent on a number of plugins being
> installed.

### Installing plugins

On the first run, all required plugins should automatically by installed by
[lazy.nvim](https://github.com/folke/lazy.nvim), a plugin manager for neovim.

All plugins are listed in [plugins.lua](./config/nvim/lua/plugins.lua). When a
plugin is added, it will automatically be installed by lazy.nvim. To interface
with lazy.nvim, simply run `:Lazy` from within vim.

> [!Note]
>
> Plugins can be synced in a headless way from the command line using the `vimu`
> alias.

## tmux configuration

I prefer to run everything inside of [tmux](https://github.com/tmux/tmux). I
typically use a large pane on the top for neovim and then multiple panes along
the bottom or right side for various commands I may need to run. There are no
pre-configured layouts in this repository, as I tend to create them on-the-fly
and as needed.

This repo ships with a `tm` command which provides a list of active session, or
provides prompts to create a new one.

```bash
> tm
Available sessions
------------------

1) New Session
Please choose your session: 1
Enter new session name: open-source
```

This configuration provides a bit of style to the tmux bar, along with some
additional data such as the currently playing song (from Apple Music or
Spotify), the system name, the session name, and the current time.

> [!Note]
>
> It also changes the prefix from `⌃-b` to `⌃-a` (⌃ is the _control_ key). This
> is because I tend to remap the Caps Lock button to Control, and then having
> the prefix makes more sense.

### tmux key commands

Pressing the Prefix followed by the following will have the following actions in
tmux.

| Command     | Description                    |
| ----------- | ------------------------------ |
| `h`         | Select the pane to the left    |
| `j`         | Select the pane to the bottom  |
| `k`         | Select the pane to the top     |
| `l`         | Select the pane to the right   |
| `⇧-H`       | Enlarge the pane to the left   |
| `⇧-J`       | Enlarge the pane to the bottom |
| `⇧-K`       | Enlarge the pane to the top    |
| `⇧-L`       | Enlarge the pane to the right  |
| `-` (dash)  | Create a vertical split        |
| `\|` (pipe) | Create a horizontal split      |

### Minimal tmux UI

Setting a `$TMUX_MINIMAL` environment variable will do some extra work to hide
the tmux status bar when there is only a single tmux window open. This is not
the default in this repo because it can be confusing, but it is my preferred way
to work. To set this, you can use the `~/.localrc` file to set it in the
following way.

```shell
export TMUX_MINIMAL=1
```

## Docker Setup

A Dockerfile exists in the repository as a testing ground for linux support. To
set up the image, make sure you have Docker installed and then run the following
command.

```bash
docker build -t dotfiles --force-rm --build-arg PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" --build-arg PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" .
```

This should create a `dotfiles` image which will set up the base environment
with the dotfiles repo cloned. To run, execute the following command.

```bash
docker run -it --rm dotfiles
```

This will open a bash shell in the container which can then be used to manually
test the dotfiles installation process with linux.

## Preferred software

I almost exclusively work on macOS, so this list will be specific to that
operating system, but several of these recommendations are also available,
cross-platform.

- [WezTerm](https://wezfurlong.org/wezterm/index.html) - A GPU-based terminal
  emulator

## Customization

The customization layer allows for a custom Lua file that can be used to tie customizations into both WezTerm and
Neovim.

### The `~/dotfiles.lua` file

To make customizations, create a `~/dotfiles.lua` file with the following content:

```lua
local config = {
  -- contents goes here...
}

return config
```
