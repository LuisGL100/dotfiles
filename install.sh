#!/bin/zsh

set -euo pipefail


############
# Homebrew #
############

# `-s` isn't working, so need to redirect output
if ! which -s brew &>/dev/null; then
  echo "Homebrew not found... installing"
  
  # TODO: run `sudo -v` to "preauthenticate", or try this: https://github.com/ptb/mac-setup/blob/2575eb0c7123b59db8b1c0ea7ded2013cb5175cd/mac-setup.command#L83
  # NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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


##############
# Oh-my-zsh! #
##############

if [[ ! -d ~/.oh-my-zsh ]]; then
  echo 'Oh-my-zsh not found... installing'
  
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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
  osascript -e "tell application \"Terminal\" to set the font name of default settings to \"MesloLGS-NF-Regular\""

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

  # TODO: `grep "^plugins=(git)$" ~/.zshrc`... but not really needed, since `sed` is checking for the full line
  sed -i "" '/^plugins=(git)$/ s/)$/ fzf-tab zsh-interactive-cd)/' ~/.zshrc

else 
  echo 'fzf detected... skipping'
fi


###########
# VS Code #
###########

if ! brew list visual-studio-code &>/dev/null; then
  brew install visual-studio-code
fi
