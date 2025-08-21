#!/bin/zsh

#############
# Functions #
#############

# This will modify "~/.zshrc", so make sure no one else is using it
function append_OMZ_Plugin_To_zshrc() {
    local PLUGIN_NAME="$1"
    awk -v my_text="plugins+=(${PLUGIN_NAME})" '
        /^plugins\+?=/ { last = NR; }
        { lines[NR] = $0; }
        END {
            for (i = 1; i <= NR; i++) {
                print lines[i];
                if (i == last) print my_text;
            }
        }
    ' ~/.zshrc > zshrc_temp
    mv zshrc_temp ~/.zshrc
}

#
function install_cask_if_required() {
  local APP=$1
  brew list "${APP}" &>/dev/null || brew install --cask "${APP}";
}

#
function install_if_required() {
  local APP=$1
  brew list "${APP}" &>/dev/null || brew install "${APP}";
}


############
# Homebrew #
############

# `-s` (silent) isn't working, so need to redirect output
if ! which -s brew &>/dev/null; then
  echo "Homebrew not found... installing"

  current_user="$(whoami)"
  # "Preauthenticate" user to avoid being prompted later on (this won't switch users). Lasts for about 15 mins.
  # Another option to try later on is this: https://github.com/ptb/mac-setup/blob/2575eb0c7123b59db8b1c0ea7ded2013cb5175cd/mac-setup.command#L83
  # And yet another option to try: https://github.com/mathiasbynens/dotfiles/blob/c886e139233320e29fd882960ba3dd388d57afd7/.macos#L13
  sudo -v
  [[ "${current_user}" != "$(whoami)" ]] && exit 1

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ ! -f ~/.zprofile ]]; then
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo '.zprofile already exists'
  fi
else
  echo 'Homebrew already installed... skipping'
fi


############
# Dotfiles #
############

if [[ ! -d ~/Documents/dotfiles ]]; then
  echo 'Dotfiles not found... installing'

  git clone https://github.com/LuisGL100/dotfiles.git ~/Documents/dotfiles

else
  echo 'Dotfiles detected... skipping'
fi


#######
# Git #
#######

if [[ ! -f ~/.gitconfig ]]; then
  echo 'Git config not found... installing'
  ln -s ~/Documents/dotfiles/git/gitconfig ~/.gitconfig
else
  echo 'Git config detected... skipping'
fi


##############
# Oh-my-zsh! #
##############

if [[ ! -d ~/.oh-my-zsh ]]; then
  echo 'Oh-my-zsh not found... installing'

  # Needs to be an "unattended" install... otherwise, you'll run into this issue:
  # https://stackoverflow.com/questions/68440855/bash-script-exits-early-after-installing-oh-my-zsh
  #
  # There's still some issue with this command... the Terminal makes a sound when it runs
  # Perhaps I should explore a different approach such as:
  # https://www.reddit.com/r/zsh/comments/riokz2/comment/hoymdph/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  ln -s ~/Documents/dotfiles/ohmyzsh/my_zsh.zsh ~/.oh-my-zsh/custom/

else
  echo 'Oh-my-zsh detected... skipping'
fi


#################
# Powerlevel10K #
#################

# First, install and set NerdFont
if ! brew list font-meslo-for-powerlevel10k &>/dev/null; then
  echo 'NerdFont Meslo not detected... installing'

  brew install --cask font-meslo-for-powerlevel10k

  # Script Editor -> File -> Open dictionary... is very useful
  # The "set font" command works by itself; however, it doesn't work when run from the script for some reason
  # I'm not sure if it's the "activate" or the "delay" that fixes it, but they work
  osascript -e "tell application \"Terminal\" to activate" -e "delay 1" -e "tell application \"Terminal\" to set the font name of default settings to \"MesloLGS-NF-Regular\""

else
  echo 'NerdFont Meslo detected... skipping'
fi

# Then, install P10K
check_font=$(osascript -e "tell application \"Terminal\" to get the font name of window 1")
if ! brew list powerlevel10k &>/dev/null && [[ "${check_font}" == "MesloLGS-NF-Regular"  ]]; then
  echo 'P10k not detected... installing'

  brew install romkatv/powerlevel10k/powerlevel10k

  echo '\n# Added by the mac_setup script' >> ~/.zshrc
  echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc

  # TODO: Now that the "dotfiles" repo is being cloned, we could use the local file instead
  curl -fsSL "https://raw.githubusercontent.com/LuisGL100/dotfiles/refs/heads/main/p10k/p10k.zsh" -o ~/.p10k.zsh

  touch "zshrc_tmp"

  >>"zshrc_tmp" print -r -- "# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
  source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"
fi
"

  >>"zshrc_tmp" print -r -- "$(cat ~/.zshrc)"

  >>"zshrc_tmp" print -r -- "
# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh"

  mv "zshrc_tmp" "${HOME}/.zshrc"

else
  echo 'P10k already installed, or NerdFont missing... skipping'
fi


###########################
# Zsh-syntax-highlighting #
###########################

if ! brew list zsh-syntax-highlighting &>/dev/null; then
  echo 'zsh-syntax-highlighting not detected... installing'

  brew install zsh-syntax-highlighting

  echo '\n# Added by the mac_setup script' >> ~/.zshrc
  echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

else
  echo 'zsh-syntax-highlighting detected... skipping'
fi


#######################
# Zsh-autosuggestions #
#######################

if ! brew list zsh-autosuggestions &>/dev/null; then
  echo 'zsh-autosuggestions not detected... installing'

  brew install zsh-autosuggestions

  echo '\n# Added by the mac_setup script' >> ~/.zshrc
  echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

else
  echo 'zsh-autosuggestions detected... skipping'
fi


#######
# FZF #
#######

if ! brew list fzf &>/dev/null; then
  echo 'fzf not detected... installing'

  brew install fzf

  echo '\n# Added by the mac_setup script' >> ~/.zshrc

  # Single quotes not needed to prevent "process substitution"... this is why:
  # https://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html
  # It is also why VS Code doesn't highlight `fzf --zsh` as a command (unlike `brew --prefix` above)
  # As further proof... try surrounding the parenthesis with backticks, like so: `(fzf --zsh)`
  # and you'll see the syntax highlight work
  echo "source <(fzf --zsh)" >> ~/.zshrc

  # fzf-tab
  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

  # sed -i "" '/^plugins=(git)$/ s/)$/ fzf-tab zsh-interactive-cd)/' ~/.zshrc
  append_OMZ_Plugin_To_zshrc "fzf-tab"
  append_OMZ_Plugin_To_zshrc "zsh-interactive-cd"

else
  echo 'fzf detected... skipping'
fi


###########
# VS Code #
###########

if ! brew list visual-studio-code &>/dev/null; then
  brew install visual-studio-code
  mkdir -p ~/Library/Application\ Support/Code/User
  ln -s ~/Documents/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
  ln -s ~/Documents/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
else
  echo 'VS Code detected... skipping'
fi


########
# Node #
########

if ! command -v node > /dev/null; then
    git clone https://github.com/lukechilds/zsh-nvm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm

    append_OMZ_Plugin_To_zshrc "zsh-nvm"

    # Manually `source` nvm this time, so we don't have to quit the Terminal to use it
    source "$HOME/.oh-my-zsh/custom/plugins/zsh-nvm/zsh-nvm.plugin.zsh"

    nvm install --lts

else
    echo "NodeJS detected... skipping"
fi


#############
# Utilities #
#############

install_cask_if_required fork


############
# Defaults #
############

# If entry doesn't exist, `Set` will give an error; likewise, `Add` will error if entry exists.
# On a new machine, this value won't exist.
# Also, it needs to be executed after installing NerdFonts; otherwise, the "AppleScript" part overwrites this
/usr/libexec/PlistBuddy -c 'Add :"Window Settings":Basic:useOptionAsMetaKey bool true' ~/Library/Preferences/com.apple.Terminal.plist

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"


########
# TEMP #
########

echo "\n# Temp" >> ~/.zshrc
echo "alias ls='ls -laFG'" >> ~/.zshrc
echo "alias vsc='open -a /Applications/Visual\ Studio\ Code.app '" >> ~/.zshrc
echo "alias vsrc='open -a /Applications/Visual\ Studio\ Code.app ~/.zshrc'" >> ~/.zshrc


#################
# Kill Terminal #
#################

# This is needed for some changes to take effect
# killall Terminal
