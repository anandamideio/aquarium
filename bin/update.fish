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

# Copy the most recent version of the aquarium repo to the aquarium directory
if not test -d $AQUARIUM_INSTALL_DIR
# Create the aquarium directory
  echo "You must install aquarium first"
  exit 1
end

# Update the system so our dependencies are up to date
print_separator "🆙 Updating your system 🆙"
sudo apt -y update && sudo apt -y upgrade

# Update Fisher
print_separator "🆙 Updating Fisher 🆙"
fish -c "fisher update"

# Run the scripts
print_separator (set_color -b blue)" Updating Aquarium "(set_color normal)
fish -c $AQUA__INSTALL_TOOLS_SCRIPT

# Update fzf and rebind our keybindings
aqua__update_fzf

# Finished updating
print_separator (set_color -b blue)" Finished Updating Aquarium "(set_color normal)
