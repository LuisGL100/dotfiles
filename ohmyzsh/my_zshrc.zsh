#############
# FUNCTIONS #
#############

function open_if_exists() {
    [[ -a "$1" ]] || return -1
    open "$1"
    return 0
}

# Get project's required Node version
# It's easy to forget which Node version was used for a project if it hasn't been used in a while
# A potential approach to figure this out is to have a look at the "package-lock.json" file and
# check what's the highest version used. This is achieved by having a look at each "node" row
# inside each "engines" section. But the issue is that there are many different "node version"
# formats to deal with.
function get_node_version() {
    if [ ! -f "package-lock.json" ]; then
        # https://stackoverflow.com/a/66438582/1202615
        printf '%s\n' 'package-lock.json not detected'
        return -1
    fi
    # These comments use a trick described here: https://stackoverflow.com/a/23872003/1202615
    # And the official reference is here (see the note): https://tldp.org/LDP/abs/html/abs-guide.html#ESCNEWLINE
    # Possible "node version formats":
    # - If "engines" value is an object:                "node": ">=0.8"
    # - If "engines" valie is an array (colon missing): "node >= 0.8"
    # - With multiple values:                           "node": "^12.20.0 || ^14.13.1 || >=16.0.0"
    # - Wildcard:                                       "node": "*"
    grep -A4 "\"engines\":" package-lock.json | # Search for "engines" and output the 4 subsequent lines
        egrep "\"node(\"| )" |                  # Only interested in "node" and "node(space)... see above
        tr -d '\"node:>=\^, \*\t' |             # Remove all chars we don't care about (this will leave dots, numbers and pipes)
        tr -s '||' ';' |                        # Convert double pipes into semicolons
        cut -d\; -f1 |                          # If line has multiple node versions, take the lowest (first) one (this assumes they're in ascending order)
        sort -V |                               # Sort based on "version number"
        tail -n1                                # Only display the last value
    return 0
}

###########
# ALIASES #
###########

alias ls='ls -laFG'
alias g='git'
alias p3='python3'
alias vsc='open -a /Applications/Visual\ Studio\ Code.app ' # trailing space is needed!: https://github.com/rothgar/mastering-zsh/blob/master/docs/helpers/aliases.md#defining-aliases
alias vsrc='open -a /Applications/Visual\ Studio\ Code.app ~/.zshrc'
alias vsmyrc='open -a /Applications/Visual\ Studio\ Code.app ~/.oh-my-zsh/custom/my_zshrc.zsh'
alias cdu='du -sch * 2>/dev/null | sort -h' # custom disk usage. 'gsort' needs 'coreutils' installed. Update: macOS' `sort` now has `-h` flag available
alias rmds='rm -Rf **/.DS_Store'
alias togglefn='~/Documents/personalmonorepo/Scripts/toggle_fn_keys.sh'

# Why does this work without `cd`? Might be an "oh-my-zsh" shortcut
# Update: this is `zsh`'s "autocd" option and it's enabled by OMZ when installed: `setopt autocd`
alias techblog='~/Documents/personalmonorepo/techblog && nvm use 22.12.0 && yarn docs:dev'

# Restart Finder
alias resfin='killall Finder'

# Remove "failed_" from filename for all files in current dir.
# This is used failed snapshot UI test cases.
alias tfail='for file in failed_*; do mv "$file" "${file#failed_}"; done;' # https://gist.github.com/larshaendler/3c477182717d32a4fc64070c283d24ad

# Copy Git's current branch to the pasteboard
# Original command:
# git branch --show-current | tr -d '\n' | pbcopy
alias pbra='git branch --show-current | tr -d '"'\n'"' | pbcopy'

# ohmyzsh's git plugin doesn't offer these aliases so adding them here
alias gbuup='git branch --unset-upstream'

############
# ENV VARS #
############

# careful! It won't always be /opt/homebrew. Check prefix with `$(brew --prefix)`
# Also, if you followed Homebrew's installation instructions, this would've been added to `.zprofile`. Probably not needed here.
# eval "$(/opt/homebrew/bin/brew shellenv)"

###########
# EXPORTS #
###########
export EDITOR='nano'

# Use Homebrew's ruby instead of the system one
if  brew list ruby &>/dev/null; then # in this context, `&` is a shortcut for both STDOUT and STDERR
    export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
    export PATH="$(brew --prefix)/lib/ruby/gems/3.1.0/bin:$PATH"
fi

# Add Python's user-base to be able to find "locally(i.e.: user) installed packages" as described here: https://docs.python-guide.org/dev/virtualenvs/#installing-pipenv
if  [[ -d $(python3 -m site --user-base) ]]; then
    export PATH="$(python3 -m site --user-base)/bin:$PATH"
fi

export DOCKER_HOST="unix:///$HOME/.colima/docker.sock" # Note, Colima needs to be running for this to work
# export FZF_DEFAULT_OPTS="--style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,Library,Applications,Music,Pictures
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target,Library,Applications,Music,Pictures
  --preview 'tree -C {}'"
