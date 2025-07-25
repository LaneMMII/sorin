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

# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/spectrum.zsh#L23 ############
typeset -AHg FX FG BG

FX=(
  reset     "%{[00m%}"
  bold      "%{[01m%}" no-bold      "%{[22m%}"
  italic    "%{[03m%}" no-italic    "%{[23m%}"
  underline "%{[04m%}" no-underline "%{[24m%}"
  blink     "%{[05m%}" no-blink     "%{[25m%}"
  reverse   "%{[07m%}" no-reverse   "%{[27m%}"
)

for color in {000..255}; do
  FG[$color]="%{[38;5;${color}m%}"
  BG[$color]="%{[48;5;${color}m%}"
done

# Show all 256 colors with color number
function spectrum_ls() {
  setopt localoptions nopromptsubst
  local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}
  for code in {000..255}; do
    print -P -- "$code: ${FG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
  done
}

# Show all 256 colors where the background is set to specific color
function spectrum_bls() {
  setopt localoptions nopromptsubst
  local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}
  for code in {000..255}; do
    print -P -- "$code: ${BG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
  done
}

##################################################################################

right_triangle() {
 echo $'\ue0b0'
}

hashtag() {
  echo $'\u266f'
}

arrow_start() {
  print -n "%{$FG[$ARROW_FG]%}%{$BG[$ARROW_BG]%}%B"
}

arrow_end() {
   print -n "%b%{$reset_color%}%{$FG[$ARROW_BG]%}%{$BG[$NEXT_ARROW_BG]%}$(right_triangle)%{$reset_color%}"
}

ok_username() {
  ARROW_FG="251"
  ARROW_BG="241"
  NEXT_ARROW_BG="153"
  print -n "$(arrow_start) %n $(arrow_end)"
}

err_username() {
  ARROW_FG="016"
  ARROW_BG="160"
  NEXT_ARROW_BG="153"
  print -n "$(arrow_start) %n $(arrow_end)"
}

current_time() {
  ARROW_FG="016"
  ARROW_BG="153"
  NEXT_ARROW_BG="000"
  print -n "$(arrow_start) %{$FG[239]%}%*%{$reset_color%} $(arrow_end)"
}

# return err_username if there are errors, ok_username otherwise
username() {
  print -n "%(?.$(ok_username).$(err_username))"
}

_prompt_node_version() {
  NODE_VERSION=$(nvm current)
  print -n " %B%F{3}${NODE_VERSION}%b"
}

_prompt() {
  print -n " λ %B%F{7}%b"
}

_directory() {
  print -n "%B%{$FG[243]%}%~%b"
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
  zstyle ':zim:git-info:branch' format ' %{$FG[235]%}%{$BG[112]%} %b %K{0}'
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
PS1='
$(username)$(current_time)
${SSH_TTY:+"%F{9}%n%F{7}@%F{3}%m "}$(_directory)%(!. %B%F{1}$(hashtag)%b.)$(_prompt)%f '

RPS1='%(?:: %F{1}✘ %?)$(_prompt_node_version)${(e)git_info[status]}%f'

SPROMPT='zsh: correct %F{1}%R%f to %F{2}%r%f [nyae]? '
