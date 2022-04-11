# vim:et sts=2 sw=2 ft=zsh
#
# A simple theme that displays relevant, contextual information.
#
# A simplified fork of the original sorin theme from
# https://github.com/sorin-ionescu/prezto/blob/master/modules/prompt/functions/prompt_sorin_setup
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

#
# 16 Terminal Colors
# -- ---------------
#  0 black
#  1 red
#  2 green
#  3 yellow
#  4 blue
#  5 magenta
#  6 cyan
#  7 white
#  8 bright black
#  9 bright red
# 10 bright green
# 11 bright yellow
# 12 bright blue
# 13 bright magenta
# 14 bright cyan
# 15 bright white
#

_prompt_node_version() {
  NODE_VERSION=$(nvm current)
  print -n " %B%F{3}${NODE_VERSION}%b"
}

_prompt_sorin_vimode() {
  case ${KEYMAP} in
    vicmd) print -n ' %B%F{2}❮%F{3}❮%F{1}❮%b' ;;
    *) print -n ' %B%F{1}❯%F{7}❯%F{4}❯%b' ;;
  esac
}

_prompt_sorin_keymap_select() {
  zle reset-prompt
  zle -R
}
if autoload -Uz is-at-least && is-at-least 5.3; then
  autoload -Uz add-zle-hook-widget && \
      add-zle-hook-widget -Uz keymap-select _prompt_sorin_keymap_select
else
  zle -N zle-keymap-select _prompt_sorin_keymap_select
fi

typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

typeset -gA git_info
if (( ${+functions[git-info]} )); then
  # Set git-info parameters.
  zstyle ':zim:git-info' verbose yes
  zstyle ':zim:git-info:action' format '%F{7}:%F{9}%s'
  zstyle ':zim:git-info:ahead' format ' %F{13}⬆'
  zstyle ':zim:git-info:behind' format ' %F{13}⬇'
  zstyle ':zim:git-info:branch' format ' %F{2}%b'
  zstyle ':zim:git-info:commit' format ' %F{3}%c'
  zstyle ':zim:git-info:indexed' format ' %F{2}🎁'
  zstyle ':zim:git-info:unindexed' format ' %F{1}🚧'
  zstyle ':zim:git-info:position' format ' %F{13}%p'
  zstyle ':zim:git-info:stashed' format ' %F{6}✭'
  zstyle ':zim:git-info:untracked' format ' %F{7}⭐'
  zstyle ':zim:git-info:keys' format \
    'status' '%%B$(coalesce "%b" "%p" "%c")%s%A%B%S%i%I%u%f%%b'

  # Add hook for calling git-info before each command.
  autoload -Uz add-zsh-hook && add-zsh-hook precmd git-info
fi

# Define prompts.
PS1='${SSH_TTY:+"%F{9}%n%F{7}@%F{3}%m "}%B%F{4}%~%b%(!. %B%F{1}#%b.)$(_prompt_sorin_vimode)%f '
RPS1='${VIRTUAL_ENV:+"%F{3}(${VIRTUAL_ENV:t})"}%(?:: %F{1}✘ %?)$(_prompt_node_version)${VIM:+" %B%F{6}V%b"}${(e)git_info[status]}%f'
SPROMPT='zsh: correct %F{1}%R%f to %F{2}%r%f [nyae]? '
