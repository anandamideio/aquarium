#!/usr/bin/env fish

# This script locates the config.fish file and appends the following fish_greeting function to the top of it

# Get the path to the config.fish file
set FISH__CONFIG_FILE "$HOME/.config/fish/config.fish"
set AQUA__CACHE_DIR "$HOME/.cache/aquarium"

# Check if the file exists
if test -f $FISH__CONFIG_FILE
    # If it does, make sure we haven't already added this function to the file
    set FUNCTION_EXISTS (grep -c "function fish_greeting" $FISH__CONFIG_FILE)
    # If the function doesn't exist, add it to the file
    if test $FUNCTION_EXISTS -eq 0
        # Back up the file before we start
        bak $FISH__CONFIG_FILE 10

        # Create cache directory if it doesn't exist
        if not test -d $AQUA__CACHE_DIR
            mkdir -p $AQUA__CACHE_DIR
        end

        echo 'function fish_greeting
            echo "Welcome to "(set_color cyan)Aquarium(set_color normal)"! Please wait a second while I throw some fishes into the water.. 🐡 🐠 🐟"
            echo "Type "(set_color yellow)help(set_color normal)" for instructions on how to use fish, or "(set_color green)"aquarium --list"(set_color normal)" to get more info on your fishies"
        end' | cat - $FISH__CONFIG_FILE > $AQUA__CACHE_DIR/temp_conf && mv $AQUA__CACHE_DIR/temp_conf $FISH__CONFIG_FILE
    end
else
    # If it doesn't, tell the user they need to install fish first then return
    echo "You need to install fish first silly"
    exit 1
end
