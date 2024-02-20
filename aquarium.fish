#!/usr/bin/env fish

function aquarium --description "Plunge into the waters"
    set -g AQUARIUM_VERSION "0.1.0"
    set -g AQUARIUM_URL "https://github.com/anandamideio/aquarium"
    set -g AQUARIUM_INSTALL_DIR "$HOME/.aquarium"
    set    AQUARIUM_PWD (pwd)
    set -l options "v/version" "h/help" "u/update" "l/list"
    argparse -n installs $options -- $argv

    # If they asked the version return it
    if set -q _flag_version
        echo (set_color blue)$AQUARIUM_VERSION(set_color normal)
        return
    end
end


