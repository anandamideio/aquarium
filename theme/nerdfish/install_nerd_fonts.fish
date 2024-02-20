#!/usr/bin/env fish

function install_nerd_fonts --description 'Interactively install NerdFonts to your system'
    # Flag options
    set -l options "h/help" "k/keep-zip" "f/force-update" "D/debug"
    argparse -n install_nerd_fonts $options -- $argv
    set -x _DEBUG_NERDFISH "False"

    if set -q _flag_force_update
        set force_update "True" # If the user provided the -f or --force-update flag
    else
        set force_update "False"
    end
    
    if set -q _flag_keep_zip
        set removeZipFiles "False" # If the user provided the -k or --keep-zip flag
    else
        set removeZipFiles "True"
    end

    if set -q _flag_D
        set _DEBUG_NERDFISH "True" # If the user provided the -D or --debug flag
    end

    function debug_msg -d 'If debug mode is enabled, prints the message to the console' -a message -d 'The message to print'
        if test "$_DEBUG_NERDFISH" = "True"
            # Grab the prefix this message is about (the thing before the ":")
            set prefix (echo $message | awk -F':' '{print $1}')
            set msg (echo $message | awk -F':' '{print $2}')
            # Print the message with a yellow prefix
            echo -n (_YELLOW) "$prefix: "(_RESET) "$msg"
            echo
        end
    end

    #defining variables
    set nerdfontsrepo 'https://api.github.com/repos/ryanoasis/nerd-fonts'
    set aFontInstalled "False"
    set os (uname)

    ## Directories to be used
    set dist_dir "$HOME/.local/share/fonts"
    # Download directory will be set to the default Downloads directory in a folder titled /NerdFonts
    set down_dir (command -V xdg-user-dir &>/dev/null && xdg-user-dir DOWNLOAD || echo "$HOME/Downloads")/NerdFonts
    set -Ux NERDFISH_CACHE_DIR (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo "$HOME/.cache")/nerdFonts

    # Run options
    set update_fonts "False"
    set isUnzip (whereis unzip | awk -F' ' '{print $2}')
    set isCurl (whereis curl | awk -F' ' '{print $2}')

    function   _RED; set_term_color red; end
    function _GREEN; set_term_color green; end
    function  _BLUE; set_term_color blue; end
    function _YELLOW; set_term_color yellow; end
    function _RESET; set_term_color normal; end
    function _TITLE; set_term_color brcyan cyan --bold; end

    if set -q _flag_debug
        echo "DEBUG MODE ENABLED"
        echo "OS: $os"
        echo "dist_dir: $dist_dir"
        echo "down_dir: $down_dir"
        echo "cache_dir: $NERDFISH_CACHE_DIR"
        echo "release_file: " $release_file
        echo "nerdfontsrepo: $nerdfontsrepo"
        echo "isUnzip: $isUnzip"
        echo "isCurl: $isCurl"
        echo "update_fonts: $update_fonts"
        echo "force_update: $force_update"
        echo "removeZipFiles: $removeZipFiles"
    end

    # Help message
    function help_message --description 'Print the help message for NerdFish'
        _TITLE
        print_separator "NerdFish: A Fishier way to install NerdFonts"
        _RESET

        _YELLOW; echo "Usage:"; _RESET

        _GREEN
        echo "-h, --help print this help message and return"
        echo "-k, --keep-zip Keep the downloaded fonts zip files"
        echo "-f, --force-update force reinstall an already installed font"
        _RESET
        echo ""
        echo "Select one or more fonts (by index/number) to install"
        echo "Hit Return/Enter to install the selected fonts"
        _RED; echo "Type 'q' to quit"; _RESET
        echo ""
        
    end

    if set -q _flag_help
        help_message # If the user provided the -h or --help flag
        return
    end

    # Check if dependencies exist
    if test -z "$isUnzip"
        _YELLOW
        echo "🤐 Dependency unzip is not installed on your system, installing now 🤐"
        _RESET
        installs unzip
    end
    if test -z "$isCurl"
        _YELLOW
        echo "➰ Dependency curl is not installed on your system, installing now ➰"
        _RESET
        installs curl
    end

    # Check if the distDir and downDir exists, if it doesn't, create it
    if not test -d "$dist_dir"
        mkdir -p "$dist_dir"
        _GREEN; echo "🗚 Created the fonts directory 🗚"; _RESET
    else
        _BLUE; echo "🗚 Fonts directory exists 🗚"; _RESET
    end
    if not test -d "$down_dir"
        mkdir -p "$down_dir"
        _GREEN; echo "🗚 Created fonts download directory 🗚"; _RESET
    else
        _BLUE; echo "🗚 Fonts download directory exists 🗚"; _RESET
    end
    if not test -d "$NERDFISH_CACHE_DIR"
        mkdir -p "$NERDFISH_CACHE_DIR"
    end

    # Handle release version
    set release_file "$NERDFISH_CACHE_DIR/release.txt"
    if test -f "$release_file"
        set cached_release (cat "$release_file")
    else
        set cached_release ""
    end

    # Variable(s) for containing how many request we can make, and how long until we can request again
    set rate_limit
    set rate_limit_reset

    # Check if font_list.json exists in the cache directory
    if not test -f "$NERDFISH_CACHE_DIR/font_list.json"
        # If it doesn't exist, download it using a silent curl command
        curl -sL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" -o "$NERDFISH_CACHE_DIR/font_list.json"


        # Update our rate limit variables
        # set rate_limit_reset (echo $release_info | jq -r '.headers."X-Ratelimit-Reset"')
        # debug_msg "Rate limit reset: $rate_limit_reset"
        # set rate_limit (echo $release_info | jq -r '.headers."X-Ratelimit-Remaining"')
        # debug_msg "Rate limit: $rate_limit"
        debug_msg "Downloaded font list to: $NERDFISH_CACHE_DIR/font_list.json"
    else
        debug_msg "Font list exists: $NERDFISH_CACHE_DIR/font_list.json"
    end

    # Set release by reading from font_list.json
    set -Ux release (jq -r '.tag_name' "$NERDFISH_CACHE_DIR/font_list.json")
    debug_msg "Release: $release"

    function download_nerdfish_fonts --description 'Download the NerdFonts'
        debug_msg "Fonts Cache file: $NERDFISH_CACHE_DIR/fonts.json"
        set downloaded_on (date)
        debug_msg "Downloaded on: $downloaded_on"

        curl -sL "https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master" -o "$NERDFISH_CACHE_DIR/fonts.json"
        debug_msg "(Re)Downloaded patched fonts options to: $NERDFISH_CACHE_DIR/fonts.json"

        jq -r --arg release "$release" --arg downloaded_on "$downloaded_on" \
    '{download_on: $downloaded_on, version: $release, fonts: [.[] | {name: .name, path: .path, sha: .sha, size: .size, url: .url, html_url: .html_url, git_url: .git_url, download_url: .download_url, type: .type, _links: ._links}]}' \
    "$NERDFISH_CACHE_DIR/fonts.json" > "$NERDFISH_CACHE_DIR/fonts.json.tmp" && mv "$NERDFISH_CACHE_DIR/fonts.json.tmp" "$NERDFISH_CACHE_DIR/fonts.json"
    end

    if not test -f "$NERDFISH_CACHE_DIR/fonts.json"; or test "$release" != (jq -r '.version' "$NERDFISH_CACHE_DIR/fonts.json")
        debug_msg "Fonts cache file does not exist or are outdated, downloading and caching"
        download_nerdfish_fonts
    end

    # If the cache exist, lets check if it's version is less than $release
    set cache_release (jq -r '.version' "$NERDFISH_CACHE_DIR/fonts.json")
    debug_msg "Cached font list is version: $cache_release"

        # Extract the font list from the JSON object
    set -l font_list (jq -r '.fonts[].name' "$NERDFISH_CACHE_DIR/fonts.json")
    debug_msg "Font list: $font_list"

    set -l fonts
    for line in (string match -r '[^\s]+' -- $font_list)
        set -a fonts $line
    end

    debug_msg "Fonts: $fonts"

    set installed_fonts_file "$NERDFISH_CACHE_DIR/installed.txt"
    if test -f "$installed_fonts_file"
        set installed_fonts_list (cat "$installed_fonts_file")
    else
        set installed_fonts_list ""
    end

    debug_msg "Installed fonts file: $installed_fonts_file"

    set -l installed_fonts
    for line in (echo "$installed_fonts_list" | string split ',' -r)
        set installed_fonts $installed_fonts $line
    end

    debug_msg "Installed fonts: $installed_fonts"

    set -x _NERDFISH_SELECTED_FONTS
    set available_fonts

    # Remove installed fonts from the list of all fonts if there is no new release
    if test "$update_fonts" = "False"
        for font in $fonts
            if not contains "$font" $installed_fonts
                set -a available_fonts $font
            else
                debug_msg "$font: is installed"
            end
        end
    else
        echo "" >"$installed_fonts_file"
        set -a available_fonts $fonts
    end

    debug_msg "Available fonts: $available_fonts"

    set -x _NERDFISH_FONT_OPTS

    # Remove already selected fonts from the menu
    if test "$force_update" = "True"
        set -a _NERDFISH_FONT_OPTS $fonts
    else
        set -a _NERDFISH_FONT_OPTS $available_fonts
    end

    debug_msg "Final Font options: $_NERDFISH_FONT_OPTS"

    function download_font --description 'Download a patched NerdFont' --argument font_name -d 'The font to download'
        _BLUE; echo "🖀 $font_name download started... 🖀"; _RESET
        curl -LJO # "https://github.com/ryanoasis/nerd-fonts/releases/download/$release/$font_name.zip"
        _GREEN; echo "☑️ $font_name download finished ☑️"; _RESET
    end

    function install_font --description 'Install a patched NerdFont' --argument font_name -d 'The font to install'
        _BLUE; echo "🖳 $font_name installation started... 🖳"; _RESET
        unzip -qqo "$font_name.zip" -d "$dist_dir/$font_name"
        _GREEN; echo "✅ $font_name installation finished ✅"; _RESET
    end

    function remove_zip_files --description 'Remove downloaded zip files'
        _BLUE; echo "🚮 Removing downloaded zip files from $down_dir... 🚮"; _RESET
        for font in $_NERDFISH_SELECTED_FONTS
            rm "$down_dir/$font.zip"
        end
        _GREEN; echo "✔️ Downloaded zip files removal succeeded! ✔️"; _RESET
    end

    function update_fonts_cache --description 'Update the fonts cache'
        _BLUE; echo "🔃 Updating fonts cache 🔃"; _RESET
        set -l output (fc-cache -f  2>&1)
        if test $status -ne  0
            _RED; echo "fc-cache: update failed!"; _RESET
            echo $output
        else
            _GREEN; echo "fc-cache: update succeeded!"; _RESET
        end
    end

    function nerdfish_menu --description 'Print the menu for NerdFish'
        _YELLOW; echo "✏️ Select one or more fonts ✏️"; _RESET

        set -l selected_fonts (printf "%s\n" $_NERDFISH_FONT_OPTS | fzf --multi --border="bold" --border-label="NerdFish Font Selection" --border-label-pos="0" --prompt="> " --marker=">" --pointer="◆" --separator="─" --preview 'extract_font_preview {}' --preview-window="right:wrap")
        set -l counter   1
        for font_name in $selected_fonts
            set _NERDFISH_SELECTED_FONTS[$counter] $font_name
            set counter (math "$counter +   1")
        end
    end

    # call the menu function to list the available fonts
    nerdfish_menu

    # Parse input like  1-3
    function parse_range --description 'Parse a range input (ex: 10-25)' --argument range -d 'The range to parse'
        if not string match -qr '^[0-9]+-[0-9]+$' -- $range
            _RED; echo "Invalid input format: $range. \n Expected format: X-Y"; _RESET
            return  1
        end

        set -l range (string split '-' -- $range)
        set -l range_start $range[1]
        set -l range_end $range[2]
        for i in (seq $range_start $range_end)
            if test $i -ge  0 -a $i -lt (count $_NERDFISH_FONT_OPTS)
                set _NERDFISH_SELECTED_FONTS[$i] $_NERDFISH_FONT_OPTS[$i]
            else
                _RED; echo "Invalid option: $i. Try again."; _RESET
                return  1
            end
        end
    end

    # Handle user input
    while true
        _BLUE;
        read -P "Enter font number(s) (e.g. 1,2,3 or 1-3 or 1,3-5): " choices
        _RESET
        for choice in (string split ',' -- $choices)
            switch $choice
                case q
                    _GREEN; echo "Goodbye!"; _RESET
                    return
                case '*-*'
                    parse_range $choice; or continue
                case '*'
                    if test (math "$choice") -ge   1 -a (math "$choice") -le (count $_NERDFISH_FONT_OPTS)
                        set _NERDFISH_SELECTED_FONTS[$choice] $_NERDFISH_FONT_OPTS[$choice]
                    else
                        _RED; echo "Invalid option: $choice. Try again."; _RESET
                        continue
                    end
            end
        end
        break
    end

    # loop over the selected fonts and download them
    if test (count $_NERDFISH_SELECTED_FONTS) -gt  0
        for i in $_NERDFISH_SELECTED_FONTS
            pushd "$down_dir" >/dev/null
            if test -f "$down_dir/$i.zip"
                rm "$down_dir/$i.zip"
            end
            download_font $i; and install_font $i; and echo $i >>"$installed_fonts_file"
            set aFontInstalled "True"
            popd >/dev/null
        end
    else
        _RED; echo "No fonts were selected, returning."; _RESET
        return
    end

    # If a font was installed
    if test "$aFontInstalled" = "True"
        # Update the fonts cache
        update_fonts_cache
        # remove downloaded archives if the option -k was not passed
        if test "$removeZipFiles" = "True"
            remove_zip_files
        else
            _GREEN; echo "🐟 The downloaded zip files can be found in $down_dir 🐟"; _RESET
        end
    end

    # remove universal variables we no longer need
    set -e release

    _GREEN;
    echo "🐟 Enjoy your new fonts 🐟";
    _RESET
end
