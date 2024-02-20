#!/usr/bin/env fish

# This script is designed to be run whenever VScode is opened

# Pre-check we need our cpfunc function to copy over our functions, since it copy then sources them.
if not type -q cpfunc
    #Copy over lsf
    cp ./.vscode/scripts/tools/lsf.fish ~/.config/fish/functions/lsf.fish
    source ~/.config/fish/functions/lsf.fish
    # Copy over our cpfunc function
    cp ./.vscode/scripts/tools/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
    # Now we need to source the new functions so that we can use them
    source ~/.config/fish/functions/cpfunc.fish
end

# Copy and Source our tools
cpfunc ./.vscode/scripts/tools -d
cpfunc ./.vscode/scripts/theme -d

# Now we should check if fisher is installed
if not type -q fisher
    if read_confirm "🎣 Fisher is not installed, installing it will provide you with some nice features. Is it alright if I install it? (y/n)"
        print_separator "🎣 Installing Fisher 🎣"
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

        # Install fisher plugins
        fisher install franciscolourenco/done # Get a notification when a long running command finishes
        fisher install jorgebucaran/spark.fish # Sparklines for fish
        fisher install meaningful-ooo/sponge # If a command returns error, don't save it to our history
        fisher install jorgebucaran/nvm.fish # Node Version Manager
        fisher install edc/bass # Use shell commands in fish
    end
end

# Install mdcat
if not type -q mdcat
    print_separator "📖 Installing mdcat 📖"
    mkdir -p ~/.cache/mdcat
    wget -P ~/.cache/mdcat https://github.com/swsnr/mdcat/releases/download/mdcat-2.1.1/mdcat-2.1.1-x86_64-unknown-linux-musl.tar.gz
    tar -xzf ~/.cache/mdcat/mdcat-2.1.1-x86_64-unknown-linux-musl.tar.gz -C ~/.cache/mdcat
    fish_add_path ~/.cache/mdcat/mdcat-2.1.1-x86_64-unknown-linux-musl/
end

# Add stuff for glow
if not type -q glow
    print_separator "🌟 Sourcing Glow 🌟"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update
end

# Install any missing ubuntu software, setting up shortcuts, virtuals, and PATHs
print_separator "🔍 Checking for missing software, installing if needed 🔍"
installs bat fd-find chafa jq glow neofetch

# Check if fzf is installed
if not type -q fzf
    print_separator "🔍 Installing fzf 🔍"
    git clone --depth  1 https://github.com/junegunn/fzf.git ~/.cache/fzf
    yes | ~/.cache/fzf/install
else
    # Get the installed version of fzf
    set -l fzf_version (fzf --version | string split ' ')[1]

    # Compare the version with "0.46.1"
    if not string match -q '*0.46.1*' $fzf_version
        print_separator "🔍 Updating fzf 🔍"
        # Check if it was installed in cache and if so pull and rebuild
        if test -d ~/.cache/fzf
            cd ~/.cache/fzf
            git pull
            yes | ~/.cache/fzf/install
        else 
            # If it wasn't installed in cache, install it in cache
            git clone --depth  1 https://github.com/junegunn/fzf.git ~/.cache/fzf
            yes | ~/.cache/fzf/install
        end
    end
end


# Now we can install timg on their system from source
if not type -q timg
    print_separator "🖼️ Installing timg 🖼️"
    # Install dependencies
    installs cmake g++ pkg-config libgraphicsmagick++-dev libturbojpeg-dev libexif-dev libswscale-dev libdeflate-dev librsvg2-dev libcairo-dev
    installs libsixel-dev libavcodec-dev libavformat-dev libavdevice-dev libopenslide-dev libpoppler-glib-dev pandoc

    mkdir -p ~/.cache/timg
    curl -sL https://github.com/hzeller/timg/releases/download/v1.6.0/timg-v1.6.0-x86_64.AppImage -o ~/.cache/timg/timg-v1.6.0-x86_64.AppImage
    # Rename it to just timg.AppImage
    mv ~/.cache/timg/timg-v1.6.0-x86_64.AppImage ~/.cache/timg/timg.AppImage
    chmod +x ~/.cache/timg/timg.AppImage
    fish_add_path ~/.cache/timg/

    # Create a fish alias so we can use it as just timg instead timg.AppImage
    alias timg="~/.cache/timg/timg.AppImage"
    funcsave timg
end

# If we don't have our neofetch alias yet lets add it
if not type -q whatami
    print_separator "🌐 Adding a sence of self (whatami) 🌐"
    alias whatami="neofetch"
    funcsave whatami
end

# Update our Git Config to return nicer
# And update all of our git alias while we are at it
print_separator "🕵️ Inspecting your Git config 🕵️"
# Query the Git configuration for visual-checkout
set visual_checkout_definition '!fish -c \'function visual-checkout
    set selected_branch (git branch --all | string replace -r "^.*\\/" "" | fzf --preview "git show --color=always --stat {}" --preview-window="right:wrap")
    if test -n "$selected_branch"
        git checkout "$selected_branch"
    else
        echo "No branch selected."
    end
end; visual-checkout\''
# Update as needed
update_git_alias "visual-checkout" $visual_checkout_definition

# Qury if Git Gone exist as well
set gone_definition '! git fetch -p && git for-each-ref --format "%(refname:short) %(upstream:track)" | awk \'$2 == "[gone]" {print $1}\' | xargs -r git branch -D'
update_git_alias "gone" $gone_definition

# Create a local variable to store the output of this grep
set -l gitColumnUI (git config --list | grep "column.ui")
if test -z $gitColumnUI
    print_separator "🕶️ Patching Git to be cooler 🕶️"
    git config --global column.ui
    git config --global branch.sort -committerdate
else
    print_separator "🕶️ Chill Git Patched 🕶️"
end

print_separator "⬆️ Updating Branch ⬆️"
git pull

print_separator "🌳 Choose what branch you'd like to work on 🌳"
git visual-checkout
git pull

print_separator "✂️ Trimming uneeded branches ✂️"
git gone

print_separator "🆙 Updating your system 🆙"
sudo apt -y update && sudo apt -y upgrade

print_separator "🧶 Rolling up most recent ball of yarn 🧶"
yarn up

print_separator "🧶 Upgrading dependencies 🧶"
yarn upgrade-interactive

print_separator "🧶 Installing newest yarn sdks 🧶"
yarn dlx @yarnpkg/sdks

print_separator "🛎️  Checking if any Services need started 🛎️"
if test -e ~/.config/fish/functions/services.fish
    source ~/.config/fish/functions/services.fish
    services
else
    print_separator  "No services to start at this time"
end

if not test -f ~/.config/aquarium_installed
    # Ask who is installing, and if we can install a special theme for them
    set -l username (whoami)

    # Patch ohmyfish to accept -y as a flag
    set -l omfInstallFilePath $OMF_PATH/bin/install


    # Check if the file exist, if so back it up
    if test -e $omfInstallFilePath
        backup_and_edit $omfInstallFilePath 5 --backup
    end

    # Overwrite the original file with our new one
    cp ./.vscode/scripts/theme/ohmyfish/install.fish $omfInstallFilePath

    # Patch the function that calls the install script to always pass the -y as a flag
    cpfunc ./.vscode/scripts/theme/ohmyfish/omf.destroy.fish

    if read_confirm "🎨 Would you like to install a special terminal theme I've designed for you, $username? (y/n)"
        # remove ohmyfish since fisher handles ohmyfish plugins, and it's better made
        set -l exit_status (omf.destroy)

        # Check the exit status
        if test $status -ne 0
            echo "Oh My Fish uninstallation failed."
            return 1 # Fail out early if we can't uninstall ohmyfish
        end

        # Install Tide
        if not type -q tide
            print_separator "🌊 Installing Tide 🌊"
            fisher install IlanCosman/tide@v6
        end

        # Path the users vscode settings to allow images in terminal
        set -l vscodeSettingsPath ./.vscode/settings.json
        set -l vscodeSettings (cat $vscodeSettingsPath)
        # Add "terminal.integrated.enableImages": true if it's not there or turn it on if it's off
        if not string match -q "terminal.integrated.enableImages" $vscodeSettings
            echo "Adding terminal.integrated.enableImages to your vscode settings"
            echo $vscodeSettings | jq '. + {"terminal.integrated.enableImages": true}' > $vscodeSettingsPath
        else
            echo "Turning on terminal.integrated.enableImages in your vscode settings"
            echo $vscodeSettings | jq '. + {"terminal.integrated.enableImages": true}' > $vscodeSettingsPath
        end

        # Make fish the default shell in VSCODE ("terminal.integrated.defaultProfile.linux": "fish")
        if not string match -q "terminal.integrated.defaultProfile.linux" $vscodeSettings
            echo "Setting terminal.integrated.defaultProfile.linux to fish in your vscode settings"
            echo $vscodeSettings | jq '. + {"terminal.integrated.defaultProfile.linux": "fish"}' > $vscodeSettingsPath
        else
            echo "Setting terminal.integrated.defaultProfile.linux to fish in your vscode settings"
            echo $vscodeSettings | jq '. + {"terminal.integrated.defaultProfile.linux": "fish"}' > $vscodeSettingsPath
        end

        # TODO: @ABOURASS -> Adjust the Nerdfish downloader to use timg to display an image scraped from the fonts repo
        # Let them choose here, then we set the theme and reload tide

        # Add a special file to the system to let us know we've installed Tide + Aquarium
        set theme_file $HOME/.config/aquarium_installed
        touch $theme_file

        if test -z (cat $theme_file)
            echo "#!/usr/bin/env fish" > $theme_file
            echo "" >> $theme_file
            echo "# This file is used to store the theme that the user has chosen" >> $theme_file
        end

        set -l CYAN__ (set_color cyan)
        set -l YELLOW__ (set_color yellow)
        set -l GREEN__ (set_color green)
        set -l RESET__ (set_color normal)
        # Set out new custom greeting since we now load asynchronously
        set -U fish_greeting "Welcome to $CYAN__Aquarium$RESET__, please wait a second while I throw some fishes into the water..\nType $YELLOW__help$RESET__ for instructions on how to use fish, or $GREEN__aquarium --list$RESET__ to list your aquarium functions"
        # Install our custom simple_git tide_item
        cpfunc ./.vscode/scripts/theme/_tide_item_simple_git.fish

        if read_confirm "🎨 Would you like to install the Lex's theme? (y/n)"
            echo "set -Ux aquarium_theme_for lex" >> $theme_file
            install_lexs_theme
        else if read_confirm "🎨 Would you like to install the Mod's theme? (y/n)"
            echo "set -Ux aquarium_theme_for mod" >> $theme_file
            install_mods_theme
        end
    end
else
    set -l aquarium_theme_for (cat ~/.config/aquarium_installed | grep -oP 'aquarium_theme_for \K\w+')
    print_separator "🎨 Loading your theme $aquarium_theme_for 🎨"

    if test -z $aquarium_theme_for
        echo "No theme set, please run the script again and choose a theme"
    else if test $aquarium_theme_for = "lex"
        set -g finish_mode "lex_theme"
    else if test $aquarium_theme_for = "mod"
        set -g finish_mode "mod_theme"
    end
end

## Last we remove any variables we set that we don't need anymore
set -e fzf_version
set -e vscodeSettingsPath
set -e NERDFISH_CACHE_DIR

print_separator "🎉 You are now up to date! 🎉"

# Now we user our finish mode to load our theme
if test -z $finish_mode
    return
else if test $finish_mode = "lex_theme"
    echo "Loading Lex's theme"
    set -e finish_mode
    install_lexs_theme
else if test $finish_mode = "mod_theme"
    echo "Loading Mod's theme"
    set -e finish_mode
    install_mods_theme
end
