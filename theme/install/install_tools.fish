#!/usr/bin/env fish

# Directories
set AQUA__PWD (pwd)

# THEME DIRECTORIES
set AQUA__THEME_DIR "$AQUA__PWD/theme"
set AQUA__THEME_FZF_DIR "$AQUA__PWD/theme/fzf"
set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
set AQUA__THEME_NERDFISH_DIR "$AQUA__PWD/theme/nerdfish"
set AQUA__THEME_TIDE_DIR "$AQUA__PWD/theme/tide"

# TOOLS DIRECTORIES
set AQUA__TOOLS_DIR "$AQUA__PWD/tools"
set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"

# AQUARIUM INSTALL DIRECTORY
set -gx AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

## SPECIAL THEME FILES
set AQUA__THEME_FZF_FILE "$AQUA__THEME_FZF_DIR/aqua__update_fzf.fish"
set AQUA__SAVE_THEME_FILE "$AQUA__THEME_DIR/save_theme.fish"

## Pre-check we need:
## - lsf (ls for files only)
## - cpfunc (Copy fish function to fish functions directory, source, make it executable)
## - bak (Backup a file)
set -l aqua__base_funcs lsf cpfunc bak
for func in $aqua__base_funcs
  cp $AQUA__FUNC_DIR/$func.fish ~/.config/fish/functions/$func.fish
  source ~/.config/fish/functions/$func.fish
end

if not test -d $AQUARIUM_INSTALL_DIR
  mkdir -p $AQUARIUM_INSTALL_DIR
end

# First do a sanity check and make sure we have the directories we need
if test -d $AQUA__CLI_DIR
  cpfunc $AQUA__CLI_DIR -d
else
  echo "Error: Could not find the cli directory; Exiting"
  exit 1
end

if test -d $AQUA__FUNC_DIR
  cpfunc $AQUA__FUNC_DIR -d
else
  echo "Error: Could not find the functions directory; Exiting"
  exit 1
end

if test -d $AQUA__UPDATE_DIR
  cpfunc $AQUA__UPDATE_DIR -d
else
  echo "Error: Could not find the update directory; Exiting"
  exit 1
end

if test -d $AQUA__THEME_NERDFISH_DIR
  cpfunc $AQUA__THEME_NERDFISH_DIR -d
else
  echo "Error: Could not find the nerdfish theme directory; Exiting"
  exit 1
end

if test -d $AQUA__THEME_TIDE_DIR
  cpfunc $AQUA__THEME_TIDE_DIR -d
else
  echo "Error: Could not find the tide theme directory; Exiting"
  exit 1
end

## Now we need to copy the special theme files
cpfunc $AQUA__THEME_FZF_FILE
cpfunc $AQUA__SAVE_THEME_FILE

## Now we also need to move them into $AQUARIUM_INSTALL_DIR/tools
mkdir -p $AQUARIUM_INSTALL_DIR/tools
cp -r $AQUA__TOOLS_DIR $AQUARIUM_INSTALL_DIR

## And copy over our theme functions
mkdir -p $AQUARIUM_INSTALL_DIR/theme
cp -r $AQUA__THEME_DIR $AQUARIUM_INSTALL_DIR
