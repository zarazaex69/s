if status is-interactive
    set fish_greeting
    
    alias ls 'eza --icons'
    alias ll 'eza --icons -l'
    alias la 'eza --icons -la'
    alias tree 'eza --icons --tree'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias icat 'lsix'
    
    set -gx GOPATH $HOME/.go
    set -gx CARGOPATH $HOME/.cargo
    set -gx BUNPATH $HOME/.bun
    set -gx LOCALPATH $HOME/.local
    
    fish_add_path $GOPATH/bin
    fish_add_path $CARGOPATH/bin
    fish_add_path $BUNPATH/bin
    fish_add_path $LOCALPATH/bin
end

starship init fish | source
