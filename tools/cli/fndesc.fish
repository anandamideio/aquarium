function fndesc -d 'Extract the function description from a fish file' -a file
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
        echo "Usage: fndesc [options] file"
        echo "Extract the function description from a fish file"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show this help message and exit"
        return
    end

    # Make sure the file exists
    if not test -f $file
        echo "File does not exist"  
        return 1
    end

    # Make sure it's a fish file
    if not string match '*.fish' $file > /dev/null
        echo "Not a fish file"
        return 1
    end

    set -l fn_desc (grep -oP 'function\\s+\\S+\\s+-d\\s+\'\\K([^\']+)' $file)

    echo $fn_desc
end
