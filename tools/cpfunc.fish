#!/usr/bin/env fish

# This is an alias function to make cp then sourcing a function easier
# It will copy the function to the fish functions directory and then source it
# Usage: cpfunc <path_to_function>
function cpfunc -d 'Copy a function to the fish functions directory and source it' -a path_to_function -d 'The path to the function to copy'
    # Version Number
    set -l func_version "1.1.2"
    # Flag options
    set -l options "v/version" "h/help" "d/directory"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: cpfunc <path_to_function>"
        echo "Version: $func_version"
        echo "Copy a function to the fish functions directory and source it"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -d, --directory  The directory to copy the function to"
        echo
        echo "Examples:"
        echo "  cpfunc ~/path/to/function.fish"
        echo "  cpfunc -d ~/path/to/functions/"
        return
    end

    # If they didn't provide a path to the function then return an error
    if not set -q path_to_function
        echo "You must provide a path to the function or function(s) to copy"
        return 1
    end

    # If they provided a directory to copy all the functions within then do that
    if set -q _flag_d
        # Confirm it's a directory
        if not test -d $path_to_function
            echo "$path_to_function is not a directory, please provide a directory"
            return 1
        end

        # If path the function doesn't end with a / then add it
        if not string match -q '*/' $path_to_function
            set path_to_function "$path_to_function/"
        end

        # Get all the files in the directory
        set -l files (lsf $path_to_function)

        # Loop through the files
        for file in $files
            # Get the function name
            set -l function_name (basename -s .fish $file)
            # Copy the function to the fish functions directory
            cp $path_to_function$file $HOME/.config/fish/functions/$function_name.fish
            # Source the function
            source $HOME/.config/fish/functions/$function_name.fish
        end
        return
    end

    # Get the function name
    # Our function paths are going to look like `./.vscode/scripts/theme/install_mods_theme.fish` so we need to extract the function name
    set -l function_name (basename -s .fish $path_to_function)

    # Copy the function to the fish functions directory
    cp $path_to_function $HOME/.config/fish/functions/$function_name.fish
    # Source the function
    source $HOME/.config/fish/functions/$function_name.fish
end
