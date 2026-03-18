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
    base-devel \
    bind \
    curl \
    libnetfilter_queue \
    ipset \
    zip \
    tcc \
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
    usbutils \
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

print_step "Configuring Pacman"
if test -f /etc/pacman.conf
    set -l needs_update 0
    
    if not grep -q "^ParallelDownloads" /etc/pacman.conf
        set needs_update 1
        print_info "Adding ParallelDownloads to pacman.conf"
    end
    
    if not grep -q "^ILoveCandy" /etc/pacman.conf
        set needs_update 1
        print_info "Adding ILoveCandy to pacman.conf"
    end
    
    if not grep -q "^\[multilib\]" /etc/pacman.conf
        set needs_update 1
        print_info "Adding multilib repository to pacman.conf"
    end
    
    if test $needs_update -eq 1
        sudo cp /etc/pacman.conf /etc/pacman.conf.backup
        print_info "Backup created: /etc/pacman.conf.backup"
        
        if not grep -q "^ParallelDownloads" /etc/pacman.conf
            sudo sed -i '/^#ParallelDownloads/c\ParallelDownloads = 16' /etc/pacman.conf
            if not grep -q "^ParallelDownloads" /etc/pacman.conf
                sudo sed -i '/\[options\]/a ParallelDownloads = 16' /etc/pacman.conf
            end
        end
        
        if not grep -q "^ILoveCandy" /etc/pacman.conf
            sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
            if not grep -q "^ILoveCandy" /etc/pacman.conf
                sudo sed -i '/\[options\]/a ILoveCandy' /etc/pacman.conf
            end
        end
        
        if not grep -q "^\[multilib\]" /etc/pacman.conf
            echo "" | sudo tee -a /etc/pacman.conf > /dev/null
            echo "[multilib]" | sudo tee -a /etc/pacman.conf > /dev/null
            echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
        end
        
        print_step "Pacman configuration updated"
        print_info "Updating package database"
        sudo pacman -Sy
    else
        print_info "Pacman already configured correctly"
    end
else
    print_error "pacman.conf not found"
end

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
    
    if test -d $SCRIPT_DIR/dots/gruvbox/firefox/theme
        print_info "Installing Gruvbox Firefox theme"
        set -l theme_xpi "$firefox_profile/extensions/gruvbox-theme@dotfiles.xpi"
        mkdir -p "$firefox_profile/extensions"
        pushd $SCRIPT_DIR/dots/gruvbox/firefox/theme
        zip -q -r -FS "$theme_xpi" manifest.json
        popd
        print_info "Gruvbox theme xpi installed to profile extensions"
    end
    
    print_info "Firefox user.js, userChrome.css and userContent.css installed to: $firefox_profile"
    print_info "Restart Firefox completely for changes to take effect"
else
    print_info "Firefox profile not found. Run Firefox once, then run this script again"
end

print_step "Setting up wallpaper"
mkdir -p ~/Pictures/Wallpapers
cp $SCRIPT_DIR/wallpapers/wind.png ~/Pictures/Wallpapers/
print_info "Wallpaper copied to ~/Pictures/Wallpapers/wind.png"

print_step "Building dynamic wallpaper generator"
cp $SCRIPT_DIR/dots/gruvbox/sway/scripts/wallpaper.c ~/.config/sway/scripts/
cp $SCRIPT_DIR/dots/gruvbox/sway/scripts/dynamic-wallpaper.sh ~/.config/sway/scripts/
chmod +x ~/.config/sway/scripts/dynamic-wallpaper.sh

if command -v tcc &> /dev/null
    tcc ~/.config/sway/scripts/wallpaper.c -o ~/.config/sway/scripts/wallgen -lm
    print_info "Compiled wallpaper generator with tcc"
else if command -v gcc &> /dev/null
    gcc -O2 ~/.config/sway/scripts/wallpaper.c -o ~/.config/sway/scripts/wallgen -lm
    print_info "Compiled wallpaper generator with gcc"
else
    print_error "No C compiler found, dynamic wallpaper will compile on first sway start"
end

print_step "Setting Fish as default shell"
set -l fish_path (command -v fish)
set -l current_shell (getent passwd $USER | cut -d: -f7)
if test "$current_shell" = "$fish_path"
    print_info "Fish is already your default shell"
else
    if not grep -qx "$fish_path" /etc/shells
        print_info "Adding $fish_path to /etc/shells"
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    end
    print_info "Changing default shell to Fish"
    sudo chsh -s $fish_path $USER
    if test $status -eq 0
        print_info "Shell changed to Fish, log out and log back in to apply"
    else
        print_error "Failed to change shell to Fish"
    end
end

print_step "Configuring Ly display manager"

if pacman -Qi ly &> /dev/null
    print_info "Installing Ly configuration with Gruvbox theme"
    
    print_info "Script directory: $SCRIPT_DIR"
    
    if test -f $SCRIPT_DIR/dots/gruvbox/ly/config.ini
        # preserve auto_login fields if already configured
        set -l old_session "null"
        set -l old_user "null"
        if test -f /etc/ly/config.ini
            set -l val (grep -Po '^\s*auto_login_session\s*=\s*\K\S.*' /etc/ly/config.ini 2>/dev/null)
            if test -n "$val"
                set old_session $val
            end
            set -l val2 (grep -Po '^\s*auto_login_user\s*=\s*\K\S.*' /etc/ly/config.ini 2>/dev/null)
            if test -n "$val2"
                set old_user $val2
            end
        end

        sudo cp $SCRIPT_DIR/dots/gruvbox/ly/config.ini /etc/ly/config.ini

        # restore auto_login values if they were not null
        if test "$old_session" != "null"
            sudo sed -i "s|^auto_login_session = .*|auto_login_session = $old_session|" /etc/ly/config.ini
            print_info "Preserved auto_login_session = $old_session"
        end
        if test "$old_user" != "null"
            sudo sed -i "s|^auto_login_user = .*|auto_login_user = $old_user|" /etc/ly/config.ini
            print_info "Preserved auto_login_user = $old_user"
        end

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

print_step "Bootloader configuration"

if test -d /sys/firmware/efi
    print_info "UEFI system detected"
    
    read -P "Do you want to install/configure Limine bootloader? [y/N]: " install_limine
    
    if test "$install_limine" = "y" -o "$install_limine" = "Y"
        if not pacman -Qi limine &> /dev/null
            print_info "Installing Limine package"
            sudo pacman -S --needed --noconfirm limine efibootmgr
        else
            print_info "Limine already installed"
        end
        
        set -l esp_path (bootctl --print-esp-path 2>/dev/null)
        
        if test -z "$esp_path"
            print_info "ESP not detected automatically"
            read -P "Enter ESP mount point (e.g., /boot or /efi): " esp_path
        else
            print_info "ESP detected at: $esp_path"
            read -P "Use this ESP path? [Y/n]: " use_esp
            
            if test "$use_esp" = "n" -o "$use_esp" = "N"
                read -P "Enter ESP mount point: " esp_path
            end
        end
        
        if test -z "$esp_path" -o ! -d "$esp_path"
            print_error "Invalid ESP path: $esp_path"
        else
            print_step "Installing Limine to ESP"
            
            sudo mkdir -p "$esp_path/EFI/limine"
            sudo cp /usr/share/limine/BOOTX64.EFI "$esp_path/EFI/limine/"
            
            if test $status -eq 0
                print_info "Limine EFI binary installed"
            else
                print_error "Failed to copy Limine EFI binary"
            end
            
            print_step "Configuring Limine"
            
            set -l root_uuid (findmnt -no UUID /)
            set -l root_device (findmnt -no SOURCE /)
            set -l root_fstype (findmnt -no FSTYPE /)
            
            if test -z "$root_uuid"
                print_error "Could not detect root UUID"
                read -P "Enter root partition UUID or device: " root_device
            else
                print_info "Root UUID: $root_uuid"
            end
            
            set -l rootflags ""
            if test "$root_fstype" = "btrfs"
                set -l root_subvol (findmnt -no OPTIONS / | grep -oP 'subvol=\K[^,]+' || echo "")
                if test -n "$root_subvol"
                    set rootflags " rootflags=subvol=$root_subvol"
                    print_info "Btrfs subvolume: $root_subvol"
                end
            end
            
            if test -f "$SCRIPT_DIR/dots/gruvbox/limine/limine.conf"
                sudo cp "$SCRIPT_DIR/dots/gruvbox/limine/limine.conf" "$esp_path/EFI/limine/"
                
                if test -n "$root_uuid"
                    sudo sed -i "s|rw\$|root=UUID=$root_uuid rw$rootflags|" "$esp_path/EFI/limine/limine.conf"
                else if test -n "$root_device"
                    sudo sed -i "s|rw\$|root=$root_device rw$rootflags|" "$esp_path/EFI/limine/limine.conf"
                end
                
                print_info "Limine config installed to: $esp_path/EFI/limine/limine.conf"
            else
                print_error "Limine config template not found"
            end
            
            print_step "Creating UEFI boot entry"
            
            set -l disk_device (lsblk -no PKNAME (findmnt -no SOURCE "$esp_path"))
            set -l part_number (lsblk -no PARTN (findmnt -no SOURCE "$esp_path"))
            
            if test -n "$disk_device" -a -n "$part_number"
                print_info "Disk: /dev/$disk_device, Partition: $part_number"
                
                if efibootmgr | grep -q "Arch Linux Limine"
                    print_info "Limine boot entry already exists"
                    read -P "Remove old entry and create new? [y/N]: " recreate_entry
                    
                    if test "$recreate_entry" = "y" -o "$recreate_entry" = "Y"
                        set -l entry_num (efibootmgr | grep "Arch Linux Limine" | sed 's/Boot\([0-9A-F]*\).*/\1/')
                        if test -n "$entry_num"
                            sudo efibootmgr -b $entry_num -B
                            print_info "Old entry removed"
                        end
                        
                        sudo efibootmgr --create --disk "/dev/$disk_device" --part "$part_number" \
                            --label "Arch Linux Limine" \
                            --loader '\EFI\limine\BOOTX64.EFI' \
                            --unicode
                        
                        if test $status -eq 0
                            print_step "Limine boot entry created successfully"
                        else
                            print_error "Failed to create boot entry"
                        end
                    end
                else
                    sudo efibootmgr --create --disk "/dev/$disk_device" --part "$part_number" \
                        --label "Arch Linux Limine" \
                        --loader '\EFI\limine\BOOTX64.EFI' \
                        --unicode
                    
                    if test $status -eq 0
                        print_step "Limine boot entry created successfully"
                    else
                        print_error "Failed to create boot entry"
                    end
                end
            else
                print_error "Could not detect disk/partition info"
                print_info "You may need to create boot entry manually:"
                print_info "efibootmgr --create --disk /dev/sdX --part Y --label 'Arch Linux Limine' --loader '\\EFI\\limine\\BOOTX64.EFI' --unicode"
            end
            
            print_step "Creating pacman hook for Limine"
            
            sudo mkdir -p /etc/pacman.d/hooks
            
            set -l hook_content "[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Deploying Limine after upgrade...
When = PostTransaction
Exec = /usr/bin/cp /usr/share/limine/BOOTX64.EFI $esp_path/EFI/limine/"
            
            echo "$hook_content" | sudo tee /etc/pacman.d/hooks/99-limine.hook > /dev/null
            
            if test $status -eq 0
                print_info "Pacman hook created: /etc/pacman.d/hooks/99-limine.hook"
            else
                print_error "Failed to create pacman hook"
            end
            
            print_step "Limine installation complete"
            print_info "Config file: $esp_path/EFI/limine/limine.conf"
            print_info "You may need to edit it to add kernel parameters or adjust paths"
        end
    else
        print_info "Skipping Limine installation"
    end
else
    print_info "Legacy BIOS system detected"
    
    read -P "Do you want to install/configure Limine bootloader (Legacy BIOS)? [y/N]: " install_limine
    
    if test "$install_limine" = "y" -o "$install_limine" = "Y"
        if not pacman -Qi limine &> /dev/null
            print_info "Installing Limine package"
            sudo pacman -S --needed --noconfirm limine
        else
            print_info "Limine already installed"
        end
        
        print_step "Configuring Limine for Legacy BIOS"
        
        set -l boot_path /boot
        
        if test ! -d "$boot_path"
            read -P "Enter boot partition mount point [/boot]: " boot_path
            test -z "$boot_path" && set boot_path /boot
        end
        
        if test -d "$boot_path"
            print_info "Using boot path: $boot_path"
            
            sudo mkdir -p "$boot_path/limine"
            
            if test -f "$SCRIPT_DIR/dots/gruvbox/limine/limine.conf"
                sudo cp "$SCRIPT_DIR/dots/gruvbox/limine/limine.conf" "$boot_path/limine/"
                
                set -l root_uuid (findmnt -no UUID /)
                set -l root_device (findmnt -no SOURCE /)
                set -l root_fstype (findmnt -no FSTYPE /)
                
                set -l rootflags ""
                if test "$root_fstype" = "btrfs"
                    set -l root_subvol (findmnt -no OPTIONS / | grep -oP 'subvol=\K[^,]+' || echo "")
                    if test -n "$root_subvol"
                        set rootflags " rootflags=subvol=$root_subvol"
                        print_info "Btrfs subvolume: $root_subvol"
                    end
                end
                
                if test -n "$root_uuid"
                    sudo sed -i "s|rw\$|root=UUID=$root_uuid rw$rootflags|" "$boot_path/limine/limine.conf"
                    print_info "Root UUID: $root_uuid"
                else if test -n "$root_device"
                    sudo sed -i "s|rw\$|root=$root_device rw$rootflags|" "$boot_path/limine/limine.conf"
                    print_info "Root device: $root_device"
                end
                
                print_info "Limine config installed to: $boot_path/limine/limine.conf"
            else
                print_error "Limine config template not found"
            end
            
            print_step "Installing Limine to disk"
            
            set -l boot_disk (lsblk -no PKNAME (findmnt -no SOURCE "$boot_path"))
            
            if test -z "$boot_disk"
                set boot_disk (lsblk -no PKNAME (findmnt -no SOURCE /))
            end
            
            if test -n "$boot_disk"
                print_info "Detected disk: /dev/$boot_disk"
                read -P "Install Limine to /dev/$boot_disk? [Y/n]: " confirm_disk
                
                if test "$confirm_disk" = "n" -o "$confirm_disk" = "N"
                    read -P "Enter disk device (e.g., sda): " boot_disk
                end
            else
                read -P "Enter disk device to install Limine (e.g., sda): " boot_disk
            end
            
            if test -n "$boot_disk" -a -b "/dev/$boot_disk"
                sudo limine bios-install "/dev/$boot_disk"
                
                if test $status -eq 0
                    print_step "Limine installed to /dev/$boot_disk"
                else
                    print_error "Failed to install Limine to disk"
                end
            else
                print_error "Invalid disk device: /dev/$boot_disk"
            end
            
            print_step "Copying Limine system files"
            sudo cp /usr/share/limine/limine-bios.sys "$boot_path/limine/"
            
            if test $status -eq 0
                print_info "Limine system files copied"
            else
                print_error "Failed to copy Limine system files"
            end
            
            print_step "Limine Legacy BIOS installation complete"
            print_info "Config file: $boot_path/limine/limine.conf"
        else
            print_error "Boot path not found: $boot_path"
        end
    else
        print_info "Skipping Limine installation"
    end
end

print_step "Installation complete!"
print_info "To start Sway, run: sway"
print_info "Or reboot to use Ly display manager"
print_info ""
print_info "Don't forget to:"
print_info "1. Log out and log back in to apply Fish shell"
print_info "2. Adjust paths in Sway config if needed"
print_info "3. Set telegram theme https://t.me/addtheme/t6WoEEBSIMdPjB73 or dots/gruvbox/telegram/gruvbox.tdesktop-theme"
print_info "4. Review Limine config if installed: /boot/EFI/limine/limine.conf"
