#!/usr/bin/env fish

function lsf -d 'List files in a directory without the directories' -a dir -d "Directory to list files from"
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options "v/version" "h/help"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: lsf [options] [dir]"
        echo "Version: $func_version"
        echo "List files in a directory without the directories"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show this help message"
        return
    end

    # if they didn't pass a directory
    if not set -q dir
        # set the directory to the current directory
        set dir "."
    end

    # list the files in the directory
    ls -p $dir | grep -v /
end
