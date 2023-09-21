#!/usr/bin/env bash

# fzf-preview: fzf preview for various file types.
#
# Used in fzf config (.zshrc) as follows:
# export FZF_CTRL_T_OPTS=" --preview 'fzf-preview {}'"

file="$1"

if [[ -d "${file}" ]]; then
  tree -C "${file}" | head -100
elif [[ $(file --mime "${file}") =~ binary ]]; then
  if [[ $(file --mime "${file}") =~ "image/" ]]; then
    columns=$(tput cols)
    columns=$((columns / 2))
    catimg -w ${columns} "${file}"
  else
    fileinfo=$(file "${file}")
    echo "${fileinfo}" && false
  fi
else
  bat --paging=never --style=numbers --color=always "${file}" 2> /dev/null | head -100
fi
