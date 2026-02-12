#!/usr/bin/env fish

set THEME "gruvbox"

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
    fuzzel \
    j4-dmenu-desktop \
    yazi \
    dunst \
    grim \
    slurp \
    swaylock \
    swaybg \
    brightnessctl \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    fastfetch \
    eza \
    imagemagick \
    cliphist \
    wl-clipboard \
    ttf-font-awesome \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji \
    xorg-xinit \
    xorg-xauth \
    git \
    git-delta \
    htop \
    zellij \
    firefox

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
    
    if not pacman -Qi ly &> /dev/null
        set -a aur_packages ly
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
mkdir -p ~/.config/fuzzel
mkdir -p ~/.config/fastfetch
mkdir -p ~/.config/eza
mkdir -p ~/.config/zellij
mkdir -p ~/.config/htop
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.mozilla/firefox

print_step "Creating user directories"
mkdir -p ~/Projects
mkdir -p ~/Builds
mkdir -p ~/Downloads
mkdir -p ~/Documents
mkdir -p ~/Pictures
mkdir -p ~/Videos
mkdir -p ~/Music
mkdir -p ~/Desktop
mkdir -p ~/.local/bin
mkdir -p ~/.local/share

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

print_step "Copying Fuzzel configuration"
cp $SCRIPT_DIR/dots/gruvbox/fuzzel/fuzzel.ini ~/.config/fuzzel/

print_step "Copying Fastfetch configuration"
cp $SCRIPT_DIR/dots/gruvbox/fastfetch/config.jsonc ~/.config/fastfetch/

print_step "Copying Eza configuration"
cp $SCRIPT_DIR/dots/gruvbox/eza/eza.conf ~/.config/eza/
cp $SCRIPT_DIR/dots/gruvbox/eza/colors ~/.config/eza/

print_step "Configuring Git"

set -l existing_name (git config --global user.name 2>/dev/null)
set -l existing_email (git config --global user.email 2>/dev/null)

if test -n "$existing_name" -a -n "$existing_email"
    print_info "Git already configured: $existing_name <$existing_email>"
    read -P "Keep existing Git config? [Y/n]: " keep_git
    
    if test "$keep_git" = "n" -o "$keep_git" = "N"
        read -P "Enter your Git name: " git_name
        read -P "Enter your Git email: " git_email
        
        if test -z "$git_name" -o -z "$git_email"
            print_error "Git name and email cannot be empty"
            exit 1
        end
        
        cp $SCRIPT_DIR/dots/gruvbox/git/config ~/.gitconfig
        sed -i "s/YOUR_NAME/$git_name/" ~/.gitconfig
        sed -i "s/YOUR_EMAIL/$git_email/" ~/.gitconfig
        
        print_info "Git config updated: $git_name <$git_email>"
    else
        cp $SCRIPT_DIR/dots/gruvbox/git/config ~/.gitconfig
        sed -i "s/YOUR_NAME/$existing_name/" ~/.gitconfig
        sed -i "s/YOUR_EMAIL/$existing_email/" ~/.gitconfig
        
        print_info "Git config updated with existing credentials"
    end
else
    read -P "Enter your Git name: " git_name
    read -P "Enter your Git email: " git_email
    
    if test -z "$git_name" -o -z "$git_email"
        print_error "Git name and email cannot be empty"
        exit 1
    end
    
    cp $SCRIPT_DIR/dots/gruvbox/git/config ~/.gitconfig
    sed -i "s/YOUR_NAME/$git_name/" ~/.gitconfig
    sed -i "s/YOUR_EMAIL/$git_email/" ~/.gitconfig
    
    print_info "Git config installed with Delta diff viewer"
    print_info "Git user: $git_name <$git_email>"
end

print_step "Copying Zellij configuration"
cp $SCRIPT_DIR/dots/gruvbox/zellij/config.kdl ~/.config/zellij/

print_step "Copying Htop configuration"
cp $SCRIPT_DIR/dots/gruvbox/htop/htoprc ~/.config/htop/

print_step "Setting up Firefox"
set -l firefox_profile (find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" 2>/dev/null | head -n 1)

if test -z "$firefox_profile"
    set firefox_profile (find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default" 2>/dev/null | head -n 1)
end

if test -n "$firefox_profile"
    cp $SCRIPT_DIR/dots/gruvbox/firefox/user.js "$firefox_profile/"
    
    mkdir -p "$firefox_profile/chrome"
    cp $SCRIPT_DIR/dots/gruvbox/firefox/userChrome.css "$firefox_profile/chrome/"
    cp $SCRIPT_DIR/dots/gruvbox/firefox/userContent.css "$firefox_profile/chrome/"
    
    print_info "Firefox user.js, userChrome.css and userContent.css installed to: $firefox_profile"
    print_info "Restart Firefox completely for changes to take effect"
else
    print_info "Firefox profile not found. Run Firefox once, then run this script again"
end

print_step "Setting up wallpaper"
mkdir -p ~/Pictures/Wallpapers
cp $SCRIPT_DIR/wallpapers/wind.png ~/Pictures/Wallpapers/
print_info "Wallpaper copied to ~/Pictures/Wallpapers/wind.png"

print_step "Setting Fish as default shell"
set -l fish_path (which fish)
set -l current_shell (getent passwd $USER | cut -d: -f7)
if test "$current_shell" != "$fish_path"
    print_info "Changing default shell to Fish"
    chsh -s $fish_path
    print_info "You need to log out and log back in for shell change to take effect"
else
    print_info "Fish is already your default shell"
end

print_step "Configuring Ly display manager"

if pacman -Qi ly &> /dev/null
    print_info "Installing Ly configuration with Gruvbox theme"
    
    print_info "Script directory: $SCRIPT_DIR"
    
    if test -f $SCRIPT_DIR/dots/gruvbox/ly/config.ini
        sudo cp $SCRIPT_DIR/dots/gruvbox/ly/config.ini /etc/ly/config.ini
        print_info "Ly config.ini installed"
    else
        print_error "Ly config.ini not found at: $SCRIPT_DIR/dots/gruvbox/ly/config.ini"
    end
    
    if test -f $SCRIPT_DIR/dots/gruvbox/ly/apply-colors.sh
        sudo mkdir -p /etc/ly
        sudo cp $SCRIPT_DIR/dots/gruvbox/ly/apply-colors.sh /etc/ly/apply-colors.sh
        sudo chmod +x /etc/ly/apply-colors.sh
        print_info "Gruvbox color script installed"
    else
        print_error "apply-colors.sh not found at: $SCRIPT_DIR/dots/gruvbox/ly/apply-colors.sh"
    end
    
    print_info "Modifying ly@.service to apply Gruvbox colors"
    set -l service_file "/usr/lib/systemd/system/ly@.service"
    
    if test -f $service_file
        if not grep -q "ExecStartPre=/etc/ly/apply-colors.sh" $service_file
            sudo sed -i '/^\[Service\]/a ExecStartPre=/etc/ly/apply-colors.sh' $service_file
            print_info "Gruvbox colors will be applied on Ly start"
        else
            print_info "Gruvbox colors already configured in service"
        end
    else
        print_error "ly@.service not found at $service_file"
    end
    
    print_step "Enabling Ly display manager"
    
    set -l current_dm (systemctl list-unit-files | grep -E 'display-manager.service' | awk '{print $2}')
    
    if test "$current_dm" = "enabled"
        print_info "Disabling current display manager"
        sudo systemctl disable display-manager.service
    end
    
    print_info "Disabling getty on tty2"
    sudo systemctl disable getty@tty2.service
    
    sudo systemctl enable ly@tty2.service
    
    if test $status -eq 0
        print_step "Ly display manager enabled successfully"
        print_info "Ly will start on tty2 with Gruvbox theme"
    else
        print_error "Failed to enable Ly display manager"
    end
else
    print_info "Ly not installed, skipping display manager configuration"
end

print_step "Installation complete!"
print_info "To start Sway, run: sway"
print_info "Or reboot to use Ly display manager"
print_info ""
print_info "Don't forget to:"
print_info "1. Log out and log back in to apply Fish shell"
print_info "2. Enable Firefox userChrome: about:config -> toolkit.legacyUserProfileCustomizations.stylesheets -> true"
print_info "3. Adjust paths in Sway config if needed"
print_info "4. Set telegram theme https://t.me/addtheme/t6WoEEBSIMdPjB73 or dots/gruvbox/telegram/gruvbox.tdesktop-theme"
