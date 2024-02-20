#!/usr/bin/env fish

# Set colors
function set_term_color -d 'Set the color of the text in terminal' -a color -d 'The color to set' -a fallback_color -d 'The fallback color to set'
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options "v/version" "h/help" "l/list"
    set -l font_options "u/underline" "b/bold" "i/italic" "d/dim" "r/reverse" "B/background="

    # Append the font options to the options list
    set -a options $font_options

    # Parse the function for flags
    argparse -n set_term_color $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # List of basic / bright colors
    set basic_colors black red green yellow blue magenta cyan white normal
    set bright_colors brblack brred brgreen bryellow brblue brmagenta brcyan brwhite

    # If they requested the list of colors, print them as a list with each line printed as the color it is
    if set -q _flag_list
        for color in $basic_colors $bright_colors
            set_color $color
            echo $color
            set_color normal
        end
        return
    end

    # If they requested help
    if set -q _flag_help
        echo "Usage: set_term_color [color] [fallback_color] [options]"
        echo "Set the color of the text in terminal"
        echo
        echo "Options:"
        echo "  -h, --help      Show this help message and exit"
        echo "  -l, --list      List all available colors"
        echo "  -u, --underline Underline the text"
        echo "  -b, --bold      Make the text bold"
        echo "  -i, --italic    Make the text italic"
        echo "  -B, --background Set the background color"
        echo "  -d, --dim       Make the text dim"
        echo "  -r, --reverse   Reverse the text"
        echo
        echo "Colors:"
        echo "  black, red, green, yellow, blue, magenta, cyan, white"
        echo "  brblack, brred, brgreen, bryellow, brblue, brmagenta, brcyan, brwhite"
        echo
        echo "Examples:"
        echo "  set_term_color red"
        echo "  set_term_color red white"
        echo "  set_term_color red white -u"
        echo "  set_term_color red white -b"
        echo "  set_term_color red white -i"
        return
    end

    if test -z "$fallback_color"
        set fallback_color normal
    end

    # If the user passed any flags to this to modify the text, we should create a string with all of them in it (Ex: '-u -b -i')
    set -l text_modifiers
    for option in $font_options
        set split_option (string split '/' -- $option)
        set option_letter $split_option[1]
        set option_name $split_option[2]

        if set -q _flag_$option_letter
            if test $option_letter = "B"
                set -a text_modifiers -b $_flag_B
            else if test $option_letter = "b"
                set -a text_modifiers -o
            else
                set -a text_modifiers $text_modifiers -$option_letter
            end
        end
    end

    # If it's in our color list or a valid HEX color
    if contains $color $basic_colors $bright_colors || string match -q '^(#?([0-9a-fA-F]{3}){1,2})$' -- $color
        set_color $color $fallback_color $text_modifiers
    else
        # If it's an invalid color, print an error and return 1
        echo "Invalid color: $color"
        return 1
    end
end
