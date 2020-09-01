ZSH=$HOME/.oh-my-zsh
# You can change the theme with another one:
#   https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="agnoster"
# DEFAULT_USER="Bryan Leighton"prompt_context(){}
VSCODE=code-insiders
# Useful plugins for Rails development with Sublime Text
plugins=(kubectl kube-ps1 gitfast git last-working-dir common-aliases sublime vscode zsh-syntax-highlighting history-substring-search node npm z)
# Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md
export HOMEBREW_NO_ANALYTICS=1
# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
# kube ps1 mods
export KUBE_PS1_ENABLED="true"
  # export KUBE_PS1_CONTEXT_ENABLE="true"
  # export KUBE_PS1_COLOR_SYMBOL="%{\e[38;5;27m%}"
  # export KUBE_PS1_COLOR_CONTEXT="%{$fg[black]%}"
  # export KUBE_PS1_COLOR_NS="%{$fg[black]%}"
PROMPT=$PROMPT'$(kube_ps1) '
# Load rbenv if installed
export PATH="${HOME}/.rbenv/bin:${PATH}"
type -a rbenv > /dev/null && eval "$(rbenv init -)"
# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"
# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"
# SET GO Path
export GOPATH="/Users/brleight/code/go"
# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
DEFAULT_USER=brleight
# prompt_context() {
#   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#     prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
#   fi
# }
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init -)"
pyenv shell 3.8.5
