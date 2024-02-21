#!/usr/bin/env fish

function update_git_alias -d 'Update a Git alias, if the definition has changed, otherwise do nothing' -a git_alias -d "The name of the Git alias to update" -a new_alias_definition -d "The new definition of the Git alias"
    # Version Number
    set -l func_version "1.1.1"
    # Flag options
    set -l options "v/version" "t/test" "h/help" "V/verbose" "s/silent"
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
        echo "  -V, --verbose  Show verbose output"
        echo "  -s, --silent   Suppress all output"
        return
    end

    # Retrieve the existing definition of the alias from the Git configuration
    set -l existing_definition (git config --get alias.$git_alias | string collect)
    # If verbose flag is set, print the existing definition
    if set -q _flag_verbose
        echo "Existing Definition: $existing_definition"
    end

    # Remove all newlines and spaces from both definitions for comparison
    set trimmed_existing_definition (string replace -r -a '\n| ' '' -- $existing_definition)
    if set -q _flag_verbose
        echo "Trimmed Existing Definition: $trimmed_existing_definition"
    end

    set new_definition (string replace -r -a '\n| ' '' -- $new_alias_definition)
    if set -q _flag_verbose
        echo "Trimmed New Definition: $new_definition"
    end

    # Update the alias if the existing definition is different from the new one
    if test -z "$trimmed_existing_definition" -o "$trimmed_existing_definition" != "$new_definition"
        if set -q _flag_verbose
            echo "Updating $git_alias alias as the definition has changed."
        end
        # If the test flag is set, then just print the command that would be run and exit
        if set -q _flag_test
            echo "Test Run: `git $git_alias` would have been updated"
            return # Don't actually update the alias if this is a dry run
        end

        if not set -q _flag_silent
            # No Test flag, so update the alias
            print_separator "🔖 Updating $git_alias Alias 🔖"
        end

        git config --global alias.$git_alias $new_alias_definition
        return # Exit with success
    else
        if not set -q _flag_silent
            print_separator "🔖 $git_alias already up to date 🔖"
        end
        return # Exit with success
    end
end
