#!/usr/bin/env fish

# Save a list of variables to be set on launch
function save_theme -d "Save a list of variables to be set on launch" -a var_key -d "The key to save the variable under" -a var_value -d "The value to save the variable as"
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options "v/version" "h/help" "r/remove" "l/list" "e/edit"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "save-theme: Save a list of variables to be set on launch"
        echo "Flags:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -r, --remove   Remove a variable from the theme"
        echo "  -l, --list     List all the variables in the theme"
        echo
        echo "Arguments:"
        echo "  theme          Either 'm' for Mod's or 'l' for Lex's"
        echo "  var_key        The key to save the variable under"
        echo "  var_value      The value to save the variable as"
        echo
        echo "Examples:"
        echo "  save-theme _SIMPLE_GIT_ICON \ue708"
    end

    # Theme file
    set theme_file "$HOME/.config/aquarium_installed"

    # If the file doesn't exist, exit
    if not test -f $HOME/.config/aquarium_installed
        echo "Theme file does not exist yet. Please install aquarium first"
        return
    end

    # Check if they just want the file listed
    if set -q _flag_list
        echo "Variables in the theme:"
        bat $theme_file
        return
    end

    # Make sure they have an editor availabel or fall back to nano
    if not set -q EDITOR
        # see if the `code` command is available
        if test -q code
            set -g EDITOR "code"
        else
            set -g EDITOR "nano"
        end
    end

    # If they want to edit the file directly open it in their editor
    if set -q _flag_edit
        $EDITOR $theme_file
        return
    end

    # Check if they supplied a key and value
    if not set -q var_key; or not set -q var_value
        echo "You must supply a key and value to save the variable under"
        return
    end

    # Check if the variable exists
    set -l var_exists (grep -q "set -Ux $var_key" $theme_file)

    # If we are in remove mode we want to remove the variable
    if set -q _flag_remove
        if $var_exists
            sed -i "/set -Ux $var_key/d" $theme_file
            printf (set_term_color green) $var_key (set_term_color normal)" has been removed from the theme"
        else
            printf (set_term_color blue) $var_key (set_term_color normal)" does not exist in this theme"
        end
        return
    end

    # If the theme file isn't executable, make it so
    if not test -x $theme_file
        chmod +x $theme_file
    end

    # if the value doesn't exist, append it
    # We want to append it like: set -Ux _SIMPLE_GIT_ICON \ue708
    if not grep -q "set -Ux $var_key $var_value" $theme_file
        echo "set -Ux $var_key $var_value" >> $theme_file
    else # Update the variable
        sed -i "s/set -Ux $var_key .*/set -Ux $var_key $var_value/" $theme_file
    end

    # Now lets parse that file and set the variables
    source $theme_file
end
