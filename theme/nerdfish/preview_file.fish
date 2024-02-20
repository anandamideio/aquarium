#!/usr/bin/env fish
#
# The purpose of this script is to demonstrate how to preview a file or an
# image in the preview window of fzf.
#
# Dependencies:
# - https://github.com/sharkdp/bat
# - https://github.com/hpjansson/chafa
# - https://iterm2.com/utilities/imgcat

function preview_file
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

    set -l file $argv[1]
    set -l type (file --dereference --mime -- $file)

    if not test (count $argv) -eq   1
        echo "usage: $0 FILENAME" >&2
        exit   1
    end

    set file (string replace -r '^~' $HOME $file)

    if not string match -qr 'image/' $type
        if string match -qr '=binary' $type
            file $file
            exit
        end

        # Sometimes bat is installed as batcat.
        if test (command -q batcat)
            set batname batcat
        else if test (command -q bat)
            set batname bat
        else
            cat $file
            exit
        end

        $batname --style=(set -q BAT_STYLE; and echo $BAT_STYLE; or echo numbers) --color=always --pager=never -- $file
        exit
    end

    set -l dim $FZF_PREVIEW_COLUMNS'x'$FZF_PREVIEW_LINES
    if test "$dim" = 'x'
        set dim (stty size < /dev/tty | awk '{print $2 "x" $1}')
    else if not set -q KITTY_WINDOW_ID && test "$FZF_PREVIEW_TOP + $FZF_PREVIEW_LINES" = (stty size < /dev/tty | awk '{print $1}')
        # Avoid scrolling issue when the Sixel image touches the bottom of the screen
        # * https://github.com/junegunn/fzf/issues/2544
        set dim $FZF_PREVIEW_COLUMNS'x'(math $FZF_PREVIEW_LINES -   1)
    end

    #   1. Use kitty icat on kitty terminal
    if test (set -q KITTY_WINDOW_ID)
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" $file | sed '$d' | sed '$s/$/\e[m/'

    #   2. Use chafa with Sixel output
    else if test (command -q chafa)
        chafa -f sixel -s "$dim" $file
        # Add a new line character so that fzf can display multiple images in the preview window
        echo

    #   3. If chafa is not found but imgcat is available, use it on iTerm2
    else if test (command -q imgcat)
        # NOTE: We should use https://iterm2.com/utilities/it2check to check if the
        # user is running iTerm2. But for the sake of simplicity, we just assume
        # that's the case here.
        imgcat -W (string split 'x' -- $dim | head -n1) -H (string split 'x' -- $dim | tail -n1) $file

    #   4. Cannot find any suitable method to preview the image
    else
        file $file
    end
end
