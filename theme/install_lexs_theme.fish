#!/usr/bin/env fish

# Lexs Theme
function install_lexs_theme --description 'Install Lexs theme'
    # Load the users theme config file
    set theme_file "$HOME/.config/aquarium_installed"

    if test -f $theme_file
        fisher update

        # This will set the theme for the current terminal
        tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Light --prompt_spacing=Sparse --icons='Many icons' --transient=Yes

        source $theme_file
    end
end
