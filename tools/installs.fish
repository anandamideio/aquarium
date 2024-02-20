#!/usr/bin/env fish

# Install (multiple) software if missing from system
function installs -d "Install (multiple pieces of) software if missing from system, without prompting for confirmation"
    # Version Number
    set -l func_version "1.0.1"
    # Flag options
    set -l options "v/version" "h/help"
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
        echo
        echo "Install (multiple pieces of) software if missing from system, without prompting for confirmation"
        return
    end
    
    # Define an (temporary) array of emojis to use when we install programs
    set install_emojis ⚒️ 🔨 🚧 ⚙️ 👷 🛠️ 🏗️ 🛠️ 🧰 🏭 🚚 🏗️ 🏭 🚜 🚧 🛠️ 🏗️

    # Install software if missing from system
    function install_program -a program -a emoji
        # Create a variable that is the program name, with any potential `-` removed
        # We do this because for some stupid reason, you install `fd-find` but the command it installs is `fdfind`
        set -l programName (string replace -r -- - "" $program)

        # Check if the program is installed
        if not type -q $programName
            print_separator "$emoji  Installing $program $emoji" # The double space here is on purpose, otherwise sometimes there no space between the emoji and the message
            sudo apt update
            sudo apt install -y $program

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
            if test $program = "bat" && not test -e ~/local/bin/bat
                ln -s $(which batcat) ~/local/bin/bat
            end

            # If the program is "fd-find" we also need to link it to "fd"
            if test $program = "fd-find" && not test -e ~/local/bin/fd
                sudo ln -s $(which fdfind) ~/local/bin/fd
            end
        end
    end

    for i in (seq (count $argv))
        set -l programToInstall $argv[$i]
        set -l emoji $install_emojis[$i]
        install_program $programToInstall $emoji
    end
end
