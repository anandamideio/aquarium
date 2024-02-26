#!/usr/bin/env fish

# AQUARIUM INSTALL DIRECTORY
set -gx AQUARIUM_INSTALL_DIR "$HOME/.aquarium"
set AQUARIUM_GIT_FUNC_DIR "$AQUARIUM_INSTALL_DIR/tools/functions"
set AQUARIUM_GIT_UPDATE_DIR "$AQUARIUM_INSTALL_DIR/tools/update"
set AQUARIUM_GIT_CLI_DIR "$AQUARIUM_INSTALL_DIR/tools/cli"

# THEME DIRECTORIES
set AQUARIUM_GIT_THEME_DIR "$AQUARIUM_INSTALL_DIR/theme"
set AQUARIUM_GIT_THEME_FZF_DIR "$AQUARIUM_GIT_THEME_DIR/fzf"
set AQUARIUM_GIT_THEME_NERDFISH_DIR "$AQUARIUM_GIT_THEME_DIR/nerdfish"
set AQUARIUM_GIT_THEME_TIDE_DIR "$AQUARIUM_GIT_THEME_DIR/tide"

# Special Theme Files
set AQUARIUM_GIT_THEME_FZF_FILE "$AQUARIUM_GIT_THEME_FZF_DIR/aqua__update_fzf.fish"
set AQUARIUM_GIT_SAVE_THEME_FILE "$AQUARIUM_GIT_THEME_DIR/save_theme.fish"

## FISH DIRS
set AQUA__FISH_FUNCTIONS_DIR "$HOME/.config/fish/functions"

## Pre-check we need:
## - lsf (ls for files only)
## - cpfunc (Copy fish function to fish functions directory, source, make it executable)
## - bak (Backup a file)
set -l aqua__base_funcs lsf cpfunc bak
for func in $aqua__base_funcs
  cp $AQUARIUM_GIT_FUNC_DIR/$func.fish $AQUA__FISH_FUNCTIONS_DIR/$func.fish
  source $AQUA__FISH_FUNCTIONS_DIR/$func.fish
end

# First do a sanity check and make sure we have the directories we need
if test -d $AQUARIUM_GIT_CLI_DIR
  cpfunc $AQUARIUM_GIT_CLI_DIR -d
else
  echo "Error: Could not find the cli directory; Exiting"
  exit 1
end

if test -d $AQUARIUM_GIT_FUNC_DIR
  cpfunc $AQUARIUM_GIT_FUNC_DIR -d
else
  echo "Error: Could not find the functions directory; Exiting"
  exit 1
end

if test -d $AQUARIUM_GIT_UPDATE_DIR
  cpfunc $AQUARIUM_GIT_UPDATE_DIR -d
else
  echo "Error: Could not find the update directory; Exiting"
  exit 1
end

if test -d $AQUARIUM_GIT_THEME_NERDFISH_DIR
  cpfunc $AQUARIUM_GIT_THEME_NERDFISH_DIR -d
else
  echo "Error: Could not find the nerdfish theme directory; Exiting"
  exit 1
end

if test -d $AQUARIUM_GIT_THEME_TIDE_DIR
  cpfunc $AQUARIUM_GIT_THEME_TIDE_DIR -d
else
  echo "Error: Could not find the tide theme directory; Exiting"
  exit 1
end

## Now we need to copy the special theme files
cpfunc $AQUARIUM_GIT_THEME_FZF_FILE
cpfunc $AQUARIUM_GIT_SAVE_THEME_FILE
