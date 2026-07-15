# shellcheck shell=bash
# AgendaCraft interactive Bash setup.
case $- in
  *i*) ;;
  *) return 0 ;;
esac

alias ll='ls -alF'
alias dcl='docker compose logs --follow --tail=200'

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
