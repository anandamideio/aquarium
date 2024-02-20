#!/usr/bin/env fish

# Each of the fonts have a readme available at `https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/${font_name}`
# In the readme, they all link their parent repos after the line: `For more information have a look at the upstream website: ${linkToParentRepo}`
# If we follow that link, there *should* be a `README.md` file that we can preview in the terminal
function extract_font_preview --description 'Extract the font preview from the font readme' --argument font_name -d 'The font to extract the preview from'
    # Lets make our cache directory if it doesn't exist
    if not test -d $NERDFISH_CACHE_DIR/fonts
        mkdir -p $NERDFISH_CACHE_DIR/fonts
    end

    if not test -f $NERDFISH_CACHE_DIR/fonts/patched_$font_name.json
        curl -sL https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts/$font_name -o $NERDFISH_CACHE_DIR/fonts/patched_$font_name.json
    end

    if not test -f $NERDFISH_CACHE_DIR/fonts/original_$font_name.md
        set -l readme_url (jq -r '.[] | select(.name == "README.md") | .download_url' $NERDFISH_CACHE_DIR/fonts/patched_$font_name.json)
        curl -sL $readme_url -o $NERDFISH_CACHE_DIR/fonts/original_$font_name.md
    end

    set -l readme_content (cat $NERDFISH_CACHE_DIR/fonts/original_$font_name.md)

    if test -z "$readme_content"
        echo "No preview available"
        return
    else
        echo $readme_content | glow -
    end
end
