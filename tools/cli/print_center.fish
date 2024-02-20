#!/usr/bin/env fish

# Function to center text within a given width
function print_center -d 'Print a message centered in terminal' -a width
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
    set -e argv[1] # Remove width argument
    set -l len (string length -- "$argv")
    if test $len -lt $width
        set -l half (math -s  0 "($width /  2)" + "($len /  2)")
        set -l rem (math -s  0 $width - $half)
        printf "%*.*s%*s\n" $half $len "$argv" $rem ' '
    else
        printf "%*.*s\n" $width $width "$argv"
    end
end
