#!/usr/bin/env fish

function update_fish_function -d "Update a fish function, if the provided version is newer (version number)" -a function_path -d "That path to the fish function to update"
    # Version Number
    set -l func_version "1.1.0"
    # Flag options
    set -l options "v/version" "t/test" "h/help"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Update a fish function, if the provided version is newer (version number)"
        echo "Usage: update_fish_function [options] function_name"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -t, --test     Test run, show what would have been updated"
        echo "  -h, --help     Show this help message"
        return
    end

    # Our function paths are going to look like `./.vscode/scripts/theme/install_mods_theme.fish` so we need to extract the function name
    set -l function_name (basename -s .fish $function_path)

    # Make sure the function exists
    if not functions --details $function_name
        echo "Function $function_name does not exist, please install using `cpfunc $function_name`"
        return
    end

    # Run the command with --version to get the version number
    set existing_version (fish -c "$function_name --version")

    # Parse the file in our scripts directory to see if it's a newer version
    set -l new_function_definition (cat $function_path)
    echo "Existing Version: $existing_version"

    # Now we eval the incoming function definition to get the version number
    set -l new_version (echo $new_function_definition | grep 'set -l func_version' | cut -d'"' -f2)
    echo "New Version: $new_version"

    # Compare the existing version with the new version
    if test -z "$existing_version" -o "$existing_version" != "$new_version"
        #If this is a test run then just print the changes
        if set -q _flag_test
            echo "Test Run: $function_name would have been updated to version $new_version"
            return
        end

        # Pre-check: We need our cpfunc function to copy over our functions
        if not type -q cpfunc
            # Copy over our cpfunc function
            cp ./.vscode/scripts/tools/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
            # Now we need to source the new functions so that we can use them
            source ~/.config/fish/functions/cpfunc.fish
        end


        # Update the function with the new definition
        cpfunc $function_path
        echo "☝️ Updated $function_name to version $new_version from $existing_version ☝️"
    else
        echo "$function_name is already up to date."
    end
end
