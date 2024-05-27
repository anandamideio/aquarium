#!/usr/bin/env fish

# Install (multiple) software if missing from system
function installs -d 'Install (multiple pieces of) software (from any source) while adding them to the path, and keeping everything up to date'
    # Version Number
    set -l func_version "1.1.0"
    # Flag options
    set -l options v/version h/help s/snap b/brew
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it and return (Added in versions 1.0.1)
    if set -q _flag_help
        echo "Usage: installs [options] <program> [program] [program] ..."
        echo
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show this help message"
        echo "  -s, --snap     Install the program using Snap"
        echo "  -b, --brew     Install the program using Homebrew"
        echo
        echo "Install (multiple pieces of) software while adding them to the path, and keeping everything up to date"
        return
    end

    # Function for extra steps for the programs that require that in Aquarium / Cauldron
    function extra_install_steps -a program
        # Check if the `~/local/bin` exist
        if not test -d ~/local/bin
            print_separator "📁 Creating ~/local/bin 📁"
            mkdir -p ~/local/bin
        end

        # Check if it's in the PATH
        if not contains ~/local/bin $fish_user_paths
            print_separator "🐟 Adding ~/local/bin to the PATH 🐟"
            # Tell Fish to add the `~/local/bin` to the path
            set -U fish_user_paths ~/local/bin $fish_user_paths
        end

        # If the program is "bat" we need to fix it's alias
        if test $program = bat && not test -e ~/local/bin/bat
            ln -s $(which batcat) ~/local/bin/bat
        end

        # If the program is "fd-find" we also need to link it to "fd"
        if test $program = fd-find && not test -e ~/local/bin/fd
            sudo ln -s $(which fdfind) ~/local/bin/fd
        end

        # If the program is 'lolcat-c' we also need to alias it
        if test $program = lolcat-c && not set -q CAULDRON_RAINBOW
            alias lolcat lolcat-c
            funcsave lolcat

            alias rainbow-fish lolcat-c
            funcsave rainbow-fish

            set -Ux CAULDRON_RAINBOW true
        end
    end

    # Define an (temporary) array of emojis to use when we install programs
    set install_emojis 🪄 ⚜️ 🧪 🔨 ⚙️ 🛠️ 🏗️ 🧰 🚚 💡
    set isFirstMissing true

    for i in (seq (count $argv))
        set -l programToInstall $argv[$i]
        set -l emoji $install_emojis[$i]

        print_separator "$emoji  Installing $program $emoji" # The double space here is on purpose, otherwise sometimes there no space between the emoji and the message
        # Create a variable that is the program name, with any potential `-` removed
        # We do this because for some stupid reason, you install `fd-find` but the command it installs is `fdfind`
        set -l short_p_name (string replace -r -- - "" $program)

        if set -q _flag_snap
            # Test if already installed
            if not test -n (snap list | grep '$programToInstall|$short_p_name')
                if $isFirstMissing
                    sudo apt update
                    sudo apt upgrade -y
                    set isFirstMissing false
                end

                snap install $programToInstall

                if test $programToInstall = lolcat-c
                    extra_install_steps $programToInstall
                end
            end
            // End current loop iteration
            continue
        else if set -q _flag_brew
            # Test if already installed
            if not test -n (brew list | grep $programToInstall)
                if $isFirstMissing
                    brew update
                    brew upgrade
                    set isFirstMissing false
                end

                brew install $programToInstall
            end
            continue
        else
            # Test if already installed
            if not type -q $programToInstall || not type -q $short_p_name
                if $isFirstMissing
                    sudo apt update
                    sudo apt upgrade -y
                    set isFirstMissing false
                end

                sudo apt install -y $programToInstall

                if test $programToInstall = fd-find || test $programToInstall = bat
                    extra_install_steps $programToInstall
                end
            end
        end
    end
end
