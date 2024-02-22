#!/usr/bin/env fish

# Directories
set AQUA__PWD (pwd)
set AQUA__THEME_DIR "$AQUA__PWD/theme"
set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"
set -Ux AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

# Scripts
set AQUA__INSTALL_TOOLS_SCRIPT "$AQUA__THEME_DIR/install/install_tools.fish"
set AQUA__INSTALL_DEPENDENCIES_SCRIPT "$AQUA__THEME_DIR/install/install_dependencies.fish"
set AQUA__INSTALL_FISH_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_fish_alias.fish"
set AQUA__INSTALL_GIT_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_git_alias.fish"
set AQUA__UNINSTALL_OMF_SCRIPT "$AQUA__THEME_DIR/ohmyfish/uninstall_omf.fish"
set AQUA__INSTALL_VSCODE_SETTINGS_SCRIPT "$AQUA__THEME_DIR/install/install_vscode_settings.fish"
set AQUA__INSTALL_NODE_SCRIPT "$AQUA__THEME_DIR/install/install_node.fish"
set PATCH_FISH_GREETING_SCRIPT "$AQUA__THEME_DIR/install/patch_greeting.fish"

# Files
set -Ux AQUA__CONFIG_FILE "$AQUARIUM_INSTALL_DIR/user_theme.fish"

# Create the aquarium directory
mkdir -p (dirname $AQUARIUM_INSTALL_DIR)

# Run the scripts
print_separator (set_color -b blue)" Installing Aquarium "(set_color normal)
fish -c $AQUA__INSTALL_TOOLS_SCRIPT
fish -c $AQUA__INSTALL_DEPENDENCIES_SCRIPT
fish -c $AQUA__INSTALL_FISH_ALIAS_SCRIPT
fish -c $AQUA__INSTALL_GIT_ALIAS_SCRIPT
fish -c $AQUA__UNINSTALL_OMF_SCRIPT
fish -c $AQUA__INSTALL_VSCODE_SETTINGS_SCRIPT
fish -c $AQUA__INSTALL_NODE_SCRIPT
fish -c $PATCH_FISH_GREETING_SCRIPT

# Install Tide
if not type -q tide
  fisher install IlanCosman/tide@v6
  
  # Install our custom simple_git tide_item
  cpfunc $AQUA__THEME_DIR/tide/_tide_item_simple_git.fish
end

# Check if the file already exists
if test -f $AQUA__CONFIG_FILE
  # If the config file already exist, make sure they want to overwrite it
  if not read_confirm "The file $AQUA__CONFIG_FILE already exists. Do you want to overwrite it? (y/n) "
    echo "Exiting..."
    exit 1
  end
end

# Create the config file
touch $AQUA__CONFIG_FILE

## The file should start as follows:
# # This file is used to store the theme that the user has chosen
# set -Ux tide_node_bg_color 493e88
# set -Ux tide_git_bg_color_unstable a30044
# set -Ux _tide_left_items vi_mode os pwd simple_git
echo "#!/usr/bin/env fish" > $AQUA__CONFIG_FILE
echo "" >> $AQUA__CONFIG_FILE
echo "# This file is used to store the theme that the user has chosen" >> $AQUA__CONFIG_FILE
echo "set -Ux tide_node_bg_color 493e88" >> $AQUA__CONFIG_FILE
echo "set -Ux tide_git_bg_color_unstable a30044" >> $AQUA__CONFIG_FILE
echo "set -Ux _tide_left_items vi_mode os pwd simple_git " >> $AQUA__CONFIG_FILE

# Set the file as executable
chmod +x $AQUA__CONFIG_FILE
# Source the file
source $AQUA__CONFIG_FILE

# cpfunc our aquarium function
cpfunc $AQUA__PWD/aquarium.fish

# Done
print_separator (set_color -b blue)" 🎉 Aquarium has been installed 🎉 "(set_color normal)
aquarium --list
