#!/usr/bin/env fish

function read_confirm --description 'Ask the user for confirmation' -a prompt
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options "v/version" "h/help" "l/list"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, print the help and return
    if set -q _flag_help
        echo "Usage: read_confirm [OPTIONS] [PROMPT]"
        echo "Ask the user for confirmation"
        echo ""
        echo "Options:"
        echo "  -v, --version  Print the version number"
        echo "  -h, --help     Print this help message"
        echo "  -l, --list     List the options"
        return
    end

    if test -z "$prompt"
        set prompt "Continue?"
    end 

    while true
        read -p 'set_color green; echo -n "$prompt [y/N]: "; set_color normal' -l confirm

        switch $confirm
            case Y y 
                return 0
            case '' N n 
                return 1
        end 
    end 
end
