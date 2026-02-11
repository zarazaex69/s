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
    swappy \
    swaylock \
    swaybg \
    brightnessctl \
    pulseaudio \
    pavucontrol \
    fastfetch \
    eza \
    imagemagick \
    ttf-font-awesome \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji

set -l packages_to_install

for pkg in $packages
    if not pacman -Qi $pkg &> /dev/null
        set -a packages_to_install $pkg
    end
end

if test (count $packages_to_install) -gt 0
    print_info "Packages to install: $packages_to_install"
    sudo pacman -S --needed --noconfirm $packages_to_install
    
    if test $status -ne 0
        print_error "Package installation failed"
        exit 1
    end
else
    print_info "All required packages are already installed"
end

print_step "Checking for yay AUR helper"

if not command -v yay &> /dev/null
    print_info "yay is not installed, installing yay-bin"
    
    set -l temp_dir (mktemp -d)
    cd $temp_dir
    
    print_info "Downloading yay-bin"
    git clone https://aur.archlinux.org/yay-bin.git
    
    if test $status -ne 0
        print_error "Failed to clone yay-bin repository"
        cd -
        rm -rf $temp_dir
    else
        cd yay-bin
        print_info "Building and installing yay-bin"
        makepkg -si --noconfirm
        
        if test $status -ne 0
            print_error "Failed to install yay-bin"
            cd -
            rm -rf $temp_dir
        else
            print_step "yay installed successfully"
            cd -
            rm -rf $temp_dir
        end
    end
else
    print_info "yay is already installed"
end

if command -v yay &> /dev/null
    print_step "Installing packages from AUR"
    
    set -l aur_packages
    
    if not pacman -Qi autotiling &> /dev/null
        set -a aur_packages autotiling
    end
    
    if not pacman -Qi lsix &> /dev/null
        set -a aur_packages lsix
    end
    
    if test (count $aur_packages) -gt 0
        print_info "Installing from AUR: $aur_packages"
        yay -S --needed --noconfirm $aur_packages
        
        if test $status -eq 0
            print_step "AUR packages installed successfully"
        else
            print_error "Failed to install some AUR packages"
        end
    else
        print_info "All AUR packages are already installed"
    end
else
    print_info "Skipping AUR packages (yay not available)"
end

print_step "Creating config directories"
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/foot
mkdir -p ~/.config/fish
mkdir -p ~/.config/dunst
mkdir -p ~/.config/yazi
mkdir -p ~/.config/bemenu
mkdir -p ~/.config/fastfetch
mkdir -p ~/.config/swappy
mkdir -p ~/Pictures/Screenshots

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

print_step "Copying Swappy configuration"
cp $SCRIPT_DIR/dots/gruvbox/swappy/config ~/.config/swappy/

print_step "Setting up wallpaper"
mkdir -p ~/Pictures/Wallpapers
cp $SCRIPT_DIR/wallpapers/wind.png ~/Pictures/Wallpapers/
print_info "Wallpaper copied to ~/Pictures/Wallpapers/wind.png"

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
print_info "2. Adjust paths in Sway config if needed"
