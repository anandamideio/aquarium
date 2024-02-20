#!/usr/bin/env fish

# Print a seperator with a centered message in the middle
function print_separator -d 'Print a separator with a centered message in the middle'
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options "v/version"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # If no flags are passed, print usage as usual
    set -l message $argv[1]
    set -l term_width (tput cols)

    # Print top separator
    printf '%.s─' (seq 1 $term_width)
    echo ""

    # Use the print_center function to center the message
    print_center $term_width "$message"

    # Print bottom separator
    printf '%.s─' (seq 1 $term_width)
    echo ""
end
