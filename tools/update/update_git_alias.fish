#!/usr/bin/env fish

function update_git_alias -d 'Update a Git alias, if the definition has changed, otherwise do nothing' -a git_alias -d "The name of the Git alias to update" -a new_alias_definition -d "The new definition of the Git alias"
    # Version Number
    set -l func_version "1.0.2"
    # Flag options
    set -l options "v/version" "t/test" "h/help"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it (added in 1.0.2)
    if set -q _flag_help
        echo "Usage: update_git_alias [OPTIONS] git_alias new_alias_definition"
        echo "Update a Git alias, if the definition has changed, otherwise do nothing"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -t, --test     Test run, don't actually update the alias"
        echo "  -h, --help     Show this help message"
        return
    end

    # Retrieve the existing definition of the alias from the Git configuration
    set -l existing_definition (git config --get-regexp "^alias\.$git_alias" | string collect)

    # Trim leading and trailing whitespace from both definitions for comparison
    set existing_definition (string trim $existing_definition)
    set new_definition (string trim $new_alias_definition)

    # Update the alias if the existing definition is different from the new one
    if test -z "$existing_definition" -o "$existing_definition" != "$new_alias_definition"
        # If the test flag is set, then just print the command that would be run and exit
        if set -q _flag_test
            echo "Test Run: `git $git_alias` would have been updated"
            return # Don't actually update the alias if this is a dry run
        end

        # No Test flag, so update the alias
        print_separator "🔖 Updating $git_alias Alias 🔖"
        git config --global alias.$git_alias $new_alias_definition
        return # Exit with success
    else
        echo "$git_alias is up to date."
        return # Exit with success
    end
end
