#!/usr/bin/env fish

# Directories
set AQUA__PWD (pwd)
set AQUA__THEME_DIR "$AQUA__PWD/theme"
set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"
set -gx AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

# Scripts
set AQUA__INSTALL_TOOLS_SCRIPT "$AQUA__THEME_DIR/install/install_tools.fish"
set AQUA__INSTALL_DEPENDENCIES_SCRIPT "$AQUA__THEME_DIR/install/install_dependencies.fish"
set AQUA__INSTALL_FISH_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_fish_alias.fish"
set AQUA__INSTALL_GIT_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_git_alias.fish"
set PATCH_FISH_GREETING_SCRIPT "$AQUA__THEME_DIR/install/patch_greeting.fish"

# Files
set -Ux AQUA__CONFIG_FILE "$AQUARIUM_INSTALL_DIR/user_theme.fish"

# Run the scripts
printf "Installing "(set_color -b blue)"Aquarium"(set_color normal)"\n"
fish -c $AQUA__INSTALL_TOOLS_SCRIPT
fish -c $AQUA__INSTALL_DEPENDENCIES_SCRIPT
fish -c $AQUA__INSTALL_FISH_ALIAS_SCRIPT
fish -c $AQUA__INSTALL_GIT_ALIAS_SCRIPT
fish -c $PATCH_FISH_GREETING_SCRIPT

# If the config file already exist, make sure they want to overwrite it
if not read_confirm "The file $AQUA__CONFIG_FILE already exists. Do you want to overwrite it? (y/n) "
  echo "Exiting..."
  exit 1
end

# Create the config file
mkdir -p (dirname $AQUA__CONFIG_FILE)

## The file should start as follows:
# # This file is used to store the theme that the user has chosen
# set -Ux tide_node_bg_color 493e88
# set -Ux tide_git_bg_color_unstable a30044
echo "#!/usr/bin/env fish" > $AQUA__CONFIG_FILE
echo "" >> $AQUA__CONFIG_FILE
echo "# This file is used to store the theme that the user has chosen" >> $AQUA__CONFIG_FILE
echo "set -Ux tide_node_bg_color 493e88" >> $AQUA__CONFIG_FILE
echo "set -Ux tide_git_bg_color_unstable a30044" >> $AQUA__CONFIG_FILE

# Set the file as executable
chmod +x $AQUA__CONFIG_FILE
# Source the file
source $AQUA__CONFIG_FILE

# Lastly cpfunc our aquarium function
cpfunc $AQUA__PWD/aquarium.fish
