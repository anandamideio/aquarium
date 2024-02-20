#!/usr/bin/env fish

# Mods Theme
function install_mods_theme --description 'Install the mods theme'
    # Load the users theme config file
    set theme_file "$HOME/.config/aquarium_installed"

    if test -f $theme_file
        # Now we run the current config file for the active terminal
        # This will set the theme for the current terminal
        tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='One line' --prompt_spacing=Sparse --icons='Many icons' --transient=No

        # Now execute the file
        source $theme_file
    end
end
