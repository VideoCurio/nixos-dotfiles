# © 2025 David BASTIEN
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

alias sudo="sudo "
alias src="source $HOME/.zshrc"                                             # reload zsh configuration
alias history="history -E 0"                                                # Force zsh to show the complete history with timestamp
alias update="sudo nixos-rebuild switch --upgrade && flatpak update -y"	    # NixOS all in one update
alias cool="fastfetch"                                                      # I always forget about this command name
alias rm="rm -I"                                                            # Better be safe
# Modern terminal tools
alias ls="eza -l"
alias cat="bat"
alias top="btop"
alias df="duf"
alias du="dust"
alias find="fd"
# Custom dotfiles
# See: https://github.com/VideoCurio/nixos-dotfiles
alias dotfiles='/run/current-system/sw/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Keep 5000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY           # append command to history file
#export HISTTIMEFORMAT="%F %T "     # History time format ? bash format ?
setopt EXTENDED_HISTORY             # record command start time
setopt HIST_FIND_NO_DUPS            # do not save duplicated command

DISABLE_AUTO_TITLE="true"

# Bitwarden SSH agent
#export SSH_AUTH_SOCK=$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
# OR system SSH agent
#eval $(ssh-agent)
#ssh-add ~/.ssh/id_ed25519
# OR config pam_ssh

# git functions
prompt_mytheme_is_git_dir() {
    cmd=$(git status 2>/dev/null)
    return $?
}

prompt_mytheme_update_git_status() {
    git_symbol=🔀
    ok_symbol=✅
    arrow_up_symbol=⬆️
    arrow_down_symbol=⬇️
    conflict_symbol=❌
    #git status --porcelain=v2 --branch --show-stash 2>/dev/null
    #git stash list
    #git rev-parse --abrev-ref HEAD --git-dir --git-common-dir 2>/dev/null

    if prompt_mytheme_is_git_dir; then
        GIT_NB_MODIF_FILES="$(git status -s -uno | wc -l)"
        PROMPT_GIT_NB_MODIF_FILES=""
        if [ "$GIT_NB_MODIF_FILES" -gt 0 ]; then
            PROMPT_GIT_NB_MODIF_FILES="|+${GIT_NB_MODIF_FILES}"
        else
            PROMPT_GIT_NB_MODIF_FILES="|${ok_symbol}"
        fi
        PROMPT_GIT_STATUS=" ${git_symbol}($(git branch --show-current)${PROMPT_GIT_NB_MODIF_FILES}) "
        echo -n "$PROMPT_GIT_STATUS"
    fi
}

# Python virtualenv
prompt_mytheme_update_venv() {
     python_symbol=🐍

     if [ -n "$VIRTUAL_ENV" ]; then
        PROMPT_VENV_BASE=" ${python_symbol}($(basename $VIRTUAL_ENV))"
        echo -n "$PROMPT_VENV_BASE"
     fi
}

# Executed before each prompt
prompt_mytheme_set_title() {
    # Terminal Title
    #echo -ne "\033]0;$LOGNAME@$(hostname -s): $(pwd|cut -d "/" -f 4-100)\007"
    echo -ne "\033]0;$LOGNAME@$(hostname -s):$(pwd|sed "s|^$HOME|~|")\007"
}

prompt_mytheme_precmd() {
    prompt_mytheme_set_title
    PROMPT="%B%K{$bg_color}%F{$font_color} ${prompt_symbol} %n@%m $PROMPT_DIRECTORY$(prompt_mytheme_update_git_status)$(prompt_mytheme_update_venv)$PROMPT_TIME$PROMPT_END$PROMPT_NEWLINE"
}

# Define custom theme, like fade but better IMO, see https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
prompt_mytheme_setup() {
    autoload -U add-zsh-hook
    add-zsh-hook precmd prompt_mytheme_precmd

    prompt_symbol=🚀
    #prompt_symbol=😎
    folder_symbol=📂
    clock_symbol=🕓

    font_color='white'
    bg_color='green' # black, red, green, yellow, blue, magenta, cyan or white
    if [ "$EUID" -eq 0 ]; then
        prompt_symbol=💀
        bg_color='red'
        font_color='white'
    elif [ "$EUID" -lt 900 ]; then
        prompt_symbol=🤖
        bg_color='yellow'
        font_color='white'
    fi

    # UTF-8 symbol code see: https://symbl.cc/en/25E4/ "$'\xe2\x97\xa4'"

    PROMPT_DIRECTORY="%K{blue}%F{$bg_color}"$'\uE0B0'" %F{white}${folder_symbol} %~ "
    PROMPT_TIME="%K{yellow}%F{blue}"$'\uE0B0'" %F{white}${clock_symbol} %D{%T (%Z)}"
    PROMPT_END="%k%b%F{yellow}"$'\uE0B0'"%F{reset}"
    PROMPT_NEWLINE="$prompt_newline %B%F{$bg_color}"$'\xe2\xa4\xb7'"%b%f "

    # Guard against OhMyZsh themes overriding MyTheme.
    unset ZSH_THEME
}

# Add git status to precmd
# add-zsh-hook preexec update_git_status
# add-zsh-hook precmd update_git_status

# Set up the prompt
setopt PROMPT_SUBST
autoload -Uz promptinit && promptinit
# Add the custom theme to promptsys
prompt_themes+=( mytheme )
# And load it
prompt mytheme

if [ -f ~/.zshrc-ai.plugin.zsh ]; then
    source ~/.zshrc-ai.plugin.zsh
fi
