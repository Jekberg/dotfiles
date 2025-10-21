#  _________  _   _ ____   ____
# |__  / ___|| | | |  _ \ / ___|
#   / /\___ \| |_| | |_) | |
#  / /_ ___) |  _  |  _ <| |___
# /____|____/|_| |_|_| \_\\____|

fastfetch

alias ls="ls --color=auto"

if [[ -f /usr/share/clang/clang-format-diff.py ]]
then
    alias clang-format-diff.py="/usr/share/clang/clang-format-diff.py"
fi

setopt BEEP

bindkey -v

KEYTIMEOUT=1

autoload edit-command-line
zle -N edit-command-line

bindkey "^[[1~"   beginning-of-line # HOME
bindkey "^[[H"    beginning-of-line # HOME
bindkey "^[[4~"   end-of-line       # END
bindkey "^[[F"    end-of-line       # END
bindkey "^[[6~"   delete-char       # DELETE

bindkey '^e'      edit-command-line

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

#  ____  ____   ___  __  __ ____ _____
# |  _ \|  _ \ / _ \|  \/  |  _ \_   _|
# | |_) | |_) | | | | |\/| | |_) || |
# |  __/|  _ <| |_| | |  | |  __/ | |
# |_|   |_| \_\\___/|_|  |_|_|    |_|

setopt PROMPT_SUBST

autoload -Uz vcs_info

function precmd() {
    vcs_info
}

# A string which will report the current VI mode
VI_MODE=

# TODO resizing the window duplicates some of the prompt.
#      ideally a resize should redraw the entire prompt.
#
# Using the ``fg`` array seems to not work so well with fill-line as it
# results in weird prompt redraws. Like wise %? also seem to mess with the
# length calculations, so for now avoid it in the fill-line.
PROMPT='
$(fill-line "%F{7}(%f%F{6}%D %T%f%F{7})%f %F{4}%~%f ${vcs_info_msg_0_} " "%B${VI_MODE}%b")
%F{7}[%f%F{1}%n%f%F{7}@%f%F{6}%m%f%F{7}]%f %B%F{7}%%%f%b '

# We set the RPROMPT dynamically and clear it in the zle-line-init and
# zle-line-finish widgets. This is so that we don't have text on the
# right side of the terminal when we resize it. So nothing persistent
# should go in here.
RPROMPT=''

# This is the error information to be displayed if and when a command returns a
# non-zero error code.
ERRNO_MSG="%F{1}%?%f"

GIT_BRANCH="%F{7}[%f%F{6}%b%f%c%u%F{7}]%f"
GIT_ACTION="%F{7}(%f%F{magenta}%f%F{6}%a%f%F{7})%f"

zstyle ':vcs_info:git*' formats                  "${GIT_BRANCH}"
zstyle ':vcs_info:git*' actionformats            "${GIT_BRANCH}${GIT_ACTION}"
zstyle ':vcs_info:git*' branchformat             "%b"
zstyle ':vcs_info:git*' stagedstr                "%F{2}+%f"
zstyle ':vcs_info:git*' unstagedstr              "%F{1}*%f"
zstyle ':vcs_info:git*' check-for-changes        true
zstyle ':vcs_info:git*' check-for-staged-changes true

function vi-keymap-select {
    # Not only do we set the VI_MODE variable to indicate which mode we
    # are in, we also set the shape of the cursor. By default we have a
    # block, but for insert mode we use a bar.
    local cursor_shape="0" # block
    case "${KEYMAP}" in
    vicmd)
        VI_MODE="-- NORMAL --"
        ;;
    viins|main)
        if [[ "${ZLE_STATE}" == *overwrite* ]]
        then
            VI_MODE="-- REPLACE --"
            cursor_shape="4" # underline
        else
            VI_MODE="-- INSERT --"
            cursor_shape="5" # bar
        fi
        ;;
    *)
        # TODO how to detect visual, visual line and visual block mode?
        #      there is a ``visual`` keymap. But it seems to never be set.
        ;;
    esac

    # Avoid a new line as it will mess with the prompt
    echo -en "\e[${cursor_shape} q"
}

function strip-ansi-graphics() {
    # There seem to be no builtin functions for stripping a string of escape
    # sequences. These escape sequences do count towards the length of a string
    # so stripping them is necessary when we try to calculate how much text
    # will be displayed.
    echo "${1}" | sed -r 's/\x1B\[[0-9]+(;[0-9]+)*m//g'
}

function fill-line() {
    # Passing in a line which includes a special prompt sequence for expansion
    # breaks this function as we calculate the columns based off the unexpanded
    # sequence. To get the correct expansion, we use `print -P`. This ensures
    # we don't wrap to the next line after the expansion. There also seem to be
    # a quirk if the text we print starts with '-'. To avoid this issue we
    # inject an empty escape sequence before the any potential -.
    local RAW_L="%{%}${1}"
    local RAW_R="%{%}${2}"
    local EXPAND_L=$(print -P "${RAW_L}")
    local EXPAND_R=$(print -P "${RAW_R}")

    # Using colours will emit escape sequences which alter the length of the
    # text but will not actually be displayed. As such, we strip them so we can
    # calculate the padding correctly.
    local TEXT_L=$(strip-ansi-graphics "${EXPAND_L}")
    local TEXT_R=$(strip-ansi-graphics "${EXPAND_R}")
    local PADDING=$((((${COLUMNS} - ${#TEXT_L})) + ((${#RAW_R} - ${#TEXT_R}))))
    print "${RAW_L}$(printf %${PADDING}s ${RAW_R})"
}

function set-window-title() {
    local WINDOW_TITLE=$1
    echo -en "\e]2;${WINDOW_TITLE} - zsh\a"
}

function zle-line-init {
    set-window-title $(print -P '%~')

    # Only show the errno if there was an actual failed previous
    # command.
    RPROMPT='%0(?..%B%F{7}<%f${ERRNO_MSG}%F{7}>%f%b)'
    vi-keymap-select
    zle reset-prompt
}

function zle-line-finish {
    # Clear the VI mode text and redraw the prompt so that we don't have it
    # appear in the previous commands. Since this is intended to be an
    # indicator of the current VI mode.
    VI_MODE=
    RPROMPT=''
    zle reset-prompt
}

function zle-keymap-select {
    vi-keymap-select
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

#   ____ ___  __  __ ____  _     _____ _____ ___ ___  _   _
#  / ___/ _ \|  \/  |  _ \| |   | ____|_   _|_ _/ _ \| \ | |
# | |  | | | | |\/| | |_) | |   |  _|   | |  | | | | |  \| |
# | |__| |_| | |  | |  __/| |___| |___  | |  | | |_| | |\  |
#  \____\___/|_|  |_|_|   |_____|_____| |_| |___\___/|_| \_|

autoload -Uz compinit
zmodload zsh/complist

compinit -d "${HOME}/.cache/zcompdump"

setopt ALWAYS_TO_END
setopt MENU_COMPLETE

zstyle :compinstall filename "${HOME}/.zshrc"
zstyle ':completion:*' verbose true
zstyle ':completion:*' menu    select

# TODO configure completions

# VI key bindings for menu selection
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

#  _   _ ___ ____ _____ ___  ______   __
# | | | |_ _/ ___|_   _/ _ \|  _ \ \ / /
# | |_| || |\___ \ | || | | | |_) \ V /
# |  _  || | ___) || || |_| |  _ < | |
# |_| |_|___|____/ |_| \___/|_| \_\|_|

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

HISTFILE=~/.cache/zhistfile
HISTSIZE=10000
SAVEHIST=10000

#  ____  _    _   _  ____ ___ _   _ ____
# |  _ \| |  | | | |/ ___|_ _| \ | / ___|
# | |_) | |  | | | | |  _ | ||  \| \___ \
# |  __/| |__| |_| | |_| || || |\  |___) |
# |_|   |_____\___/ \____|___|_| \_|____/

function load-plugin()
{
    # This function is just a utility for loading plugins.
    #
    # We expect at most 2 arguments:
    #
    # - The first argument is the name of the plugin. The expectation is that
    #   this is the directory name.
    # - The second argument is the actual file name which should be included
    #   to activate the plugin.
    #
    # If the second argument is omitted, we guess that it has the same name as
    # the dir suffixed by a zsh extension.
    local plugin_name="${1}"
    local plugin_file="${2:-${plugin_name}.zsh}"

    # Plugins installed via package managers don't always seem to use the same
    # install path. This just makes this file not work across different systems
    # without modifications. So we define a search order where we expect to
    # find plugins. Likewise, we may want to install plugins for a specific
    # user only, so we first search in the home directory.
    local plugin_paths=("${HOME}/.local/zsh/plugins/${plugin_name}/${plugin_file}"
                        "/usr/share/zsh/plugin/${plugin_name}/${plugin_file}"
                        "/usr/share/zsh/${plugin_name}/${plugin_file}"
                        "/usr/share/zsh/site-functions/${plugin_file}"
                        "/usr/share/${plugin_name}/${plugin_file}"
                        )
    for plugin_path in $plugin_paths
    do
        [[ -f "${plugin_path}" ]] && source "${plugin_path}" && break
    done
}

load-plugin zsh-autosuggestions
load-plugin zsh-syntax-highlighting

