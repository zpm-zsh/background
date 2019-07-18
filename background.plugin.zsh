#!/usr/bin/env zsh

TMOUT=5

TRAPALRM() {
  for fn in $background_functions; do
    $fn
  done
}

function add-hook(){
  emulate -L zsh
  
  local -a hooktypes
  hooktypes=(
    chpwd precmd preexec periodic zshaddhistory zshexit
    zsh_directory_name background
  )
  local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes"
  
  local opt
  local -a autoopts
  integer del list help
  
  while getopts "dDhLUzk" opt; do
    case $opt in
      (d)
      del=1
      ;;
  
      (D)
      del=2
      ;;
  
      (h)
      help=1
      ;;
  
      (L)
      list=1
      ;;
  
      ([Uzk])
      autoopts+=(-$opt)
      ;;
  
      (*)
      return 1
      ;;
    esac
  done
  shift $(( OPTIND - 1 ))
  
  if (( list )); then
    typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
    return $?
  elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 )); then
    print -u$(( 2 - help )) $usage
    return $(( 1 - help ))
  fi
  
  local hook="${1}_functions"
  local fn="$2"
  
  if (( del )); then
    # delete, if hook is set
    if (( ${(P)+hook} )); then
      if (( del == 2 )); then
        set -A $hook ${(P)hook:#${~fn}}
      else
        set -A $hook ${(P)hook:#$fn}
      fi
      # unset if no remaining entries --- this can give better
      # performance in some cases
      if (( ! ${(P)#hook} )); then
        unset $hook
      fi
    fi
  else
    if (( ${(P)+hook} )); then
      if (( ${${(P)hook}[(I)$fn]} == 0 )); then
        typeset -ga $hook
        set -A $hook ${(P)hook} $fn
      fi
    else
      typeset -ga $hook
      set -A $hook $fn
    fi
    autoload $autoopts -- $fn
  fi

}
