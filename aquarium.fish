#!/usr/bin/env fish

function aquarium -d 'Plunge into the waters'
    # Directories
    set AQUA__PWD (pwd)
    set AQUA__THEME_DIR "$AQUA__PWD/theme"
    set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
    set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
    set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
    set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"

    # Scripts
    set AQUA__INSTALL_TOOLS_SCRIPT "$AQUA__THEME_DIR/install/install_tools.fish"
    set AQUA__INSTALL_DEPENDENCIES_SCRIPT "$AQUA__THEME_DIR/install/install_dependencies.fish"
    set AQUA__INSTALL_FISH_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_fish_alias.fish"
    set AQUA__INSTALL_GIT_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_git_alias.fish"
    set PATCH_FISH_GREETING_SCRIPT "$AQUA__THEME_DIR/install/patch_greeting.fish"

    # Files
    set -Ux AQUA__CONFIG_FILE "$AQUARIUM_INSTALL_DIR/user_theme.fish"

    # Settings
    set -Ux AQUARIUM_VERSION "0.1.0"
    set -Ux AQUARIUM_URL "https://github.com/anandamideio/aquarium"

    # Flags
    set -l options "v/version" "h/help" "u/update" "l/list" "e/edit"
    argparse -n installs $options -- $argv

    # If they asked the version return it
    if set -q _flag_version
        echo (set_color blue)$AQUARIUM_VERSION(set_color normal)
        return
    end

    # If they asked for help return it
    if set -q _flag_help
        echo "Usage: aquarium [options]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version"
        echo "  -h, --help     Show this help"
        echo "  -u, --update   Update aquarium"
        echo "  -l, --list     List installed aquariums"
        echo "  -e, --edit     Edit installed aquariums"
        return
    end

    # If they asked to edit the theme run `save_theme -e"
    if set -q _flag_edit
        save_theme -e
        return
    end

    # If they asked to list the functions provided via aquarium list them in a pretty way
    if set -q _flag_list
        set -l fn_fishies (lsf $AQUA__FUNC_DIR)
        set -l cli_fishies (lsf $AQUA__CLI_DIR)
        set -l update_fishies (lsf $AQUA__UPDATE_DIR)

        echo (set_color green)"Useful Functions:"(set_color normal)
        for fn in $fn_fishies
            echo "" • $fn -- (set_color blue)(fndesc $AQUA__FUNC_DIR/$fn)(set_color normal)
        end
        echo ""

        echo (set_color yellow)"CLI Functions:"(set_color normal)
        for cli in $cli_fishies
            echo "" • $cli -- (set_color blue)(fndesc $AQUA__CLI_DIR/$cli)(set_color normal)
        end
        echo ""

        echo (set_color red)"Update Functions:"(set_color normal)
        for update in $update_fishies
            echo "" • $update -- (set_color blue)(fndesc $AQUA__UPDATE_DIR/$update)(set_color normal)
        end
    end
end


