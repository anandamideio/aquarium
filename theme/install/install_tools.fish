#!/usr/bin/env fish

# Directories
set AQUA__PWD (pwd)
set AQUA__THEME_DIR "$AQUA__PWD/theme"
set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"
set -gx AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

## Pre-check we need:
## - lsf (ls for files only)
## - cpfunc (Copy fish function to fish functions directory, source, make it executable)
set -l aqua__base_funcs lsf cpfunc bak
for func in $aqua__base_funcs
  cp $AQUA__FUNC_DIR/$func.fish ~/.config/fish/functions/$func.fish
  source ~/.config/fish/functions/$func.fish
end

## Now we use the cpfunc -d to copy all our aqua functions to the fish functions directory
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

## Now we also need to move them into $AQUARIUM_INSTALL_DIR/tools
mkdir -p $AQUARIUM_INSTALL_DIR/tools/cli
cp -r $AQUA__CLI_DIR $AQUARIUM_INSTALL_DIR/tools/cli

mkdir -p $AQUARIUM_INSTALL_DIR/tools/functions
cp -r $AQUA__FUNC_DIR $AQUARIUM_INSTALL_DIR/tools/functions

mkdir -p $AQUARIUM_INSTALL_DIR/tools/update
cp -r $AQUA__UPDATE_DIR $AQUARIUM_INSTALL_DIR/tools/update
