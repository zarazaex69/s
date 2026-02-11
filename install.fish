#!/usr/bin/env fish

set -l SCRIPT_DIR (dirname (status --current-filename))

function print_step
    set_color green
    echo "===> $argv"
    set_color normal
end

function print_error
    set_color red
    echo "ERROR: $argv"
    set_color normal
end

function print_info
    set_color yellow
    echo "INFO: $argv"
    set_color normal
end

print_step "Starting Sway Gruvbox dotfiles installation"

if not test -f /etc/arch-release
    print_error "This script is designed for Arch Linux"
    exit 1
end

print_step "Installing required packages"

set -l packages \
    sway \
    waybar \
    foot \
    fish \
    starship \
    bemenu \
    yazi \
    dunst \
    grim \
    slurp \
    swaylock \
    swaybg \
    brightnessctl \
    pulseaudio \
    pavucontrol \
    fastfetch \
    ttf-font-awesome \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji

print_info "Packages to install: $packages"
sudo pacman -S --needed $packages

if test $status -ne 0
    print_error "Package installation failed"
    exit 1
end

print_step "Installing autotiling from AUR (optional)"
print_info "You can install autotiling manually with: yay -S autotiling"

print_step "Creating config directories"
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/foot
mkdir -p ~/.config/fish
mkdir -p ~/.config/dunst
mkdir -p ~/.config/yazi
mkdir -p ~/.config/bemenu
mkdir -p ~/.config/fastfetch

print_step "Copying Sway configuration"
cp -r $SCRIPT_DIR/dots/gruvbox/sway/config ~/.config/sway/
cp -r $SCRIPT_DIR/dots/gruvbox/sway/conf.d ~/.config/sway/
if test -d $SCRIPT_DIR/dots/gruvbox/sway/scripts
    cp -r $SCRIPT_DIR/dots/gruvbox/sway/scripts ~/.config/sway/
end

print_step "Copying Waybar configuration"
cp $SCRIPT_DIR/dots/gruvbox/waybar/config ~/.config/waybar/
cp $SCRIPT_DIR/dots/gruvbox/waybar/style.css ~/.config/waybar/

print_step "Copying Foot configuration"
cp $SCRIPT_DIR/dots/gruvbox/foot/foot.ini ~/.config/foot/

print_step "Copying Fish configuration"
cp $SCRIPT_DIR/dots/gruvbox/fish/config.fish ~/.config/fish/

print_step "Copying Starship configuration"
cp $SCRIPT_DIR/dots/gruvbox/starship/starship.toml ~/.config/starship.toml

print_step "Copying Dunst configuration"
cp $SCRIPT_DIR/dots/gruvbox/dunst/dunstrc ~/.config/dunst/

print_step "Copying Yazi configuration"
cp $SCRIPT_DIR/dots/gruvbox/yazi/yazi.toml ~/.config/yazi/
cp $SCRIPT_DIR/dots/gruvbox/yazi/theme.toml ~/.config/yazi/
if test -d $SCRIPT_DIR/dots/gruvbox/yazi/flavors
    cp -r $SCRIPT_DIR/dots/gruvbox/yazi/flavors ~/.config/yazi/
end

print_step "Copying Bemenu configuration"
if test -f $SCRIPT_DIR/dots/gruvbox/bemenu/bemenu-command.txt
    cp $SCRIPT_DIR/dots/gruvbox/bemenu/bemenu-command.txt ~/.config/bemenu/
end

print_step "Copying Fastfetch configuration"
cp $SCRIPT_DIR/dots/gruvbox/fastfetch/config.jsonc ~/.config/fastfetch/

print_step "Setting Fish as default shell"
if not string match -q (which fish) $SHELL
    print_info "Changing default shell to Fish"
    chsh -s (which fish)
    print_info "You need to log out and log back in for shell change to take effect"
else
    print_info "Fish is already your default shell"
end

print_step "Installation complete!"
print_info "To start Sway, run: sway"
print_info "Or add it to your display manager"
print_info ""
print_info "Don't forget to:"
print_info "1. Log out and log back in to apply Fish shell"
print_info "2. Install autotiling: yay -S autotiling"
print_info "3. Copy wallpapers to your preferred location"
print_info "4. Adjust paths in Sway config if needed"
