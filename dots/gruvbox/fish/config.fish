if status is-interactive
    alias ls='eza --icons'
    alias ll='eza --icons -l'
    alias la='eza --icons -la'
    alias tree='eza --icons --tree'
end

starship init fish | source
