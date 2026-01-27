# ~/.config/fish/config.fish
starship init fish | source

# overwrite greeting
function fish_greeting
    rxfetch
end

# Useful aliases
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.="eza -a | grep -e '^\.'"

alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias mirror="sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"

export EDITOR=micro