#!/usr/bin/env fish

# Directories
set AQUA__PWD (pwd)
set AQUA__THEME_DIR "$AQUA__PWD/theme"
set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"

## Pre-check we need:
## - lsf (ls for files only)
## - cpfunc (Copy fish function to fish functions directory, source, make it executable)
set -l aqua__base_funcs lsf cpfunc
for func in $aqua__base_funcs
  if not type -q $func
    cp $AQUA__FUNC_DIR/$func.fish ~/.config/fish/functions/$func.fish
    source ~/.config/fish/functions/$func.fish
  end
end

## Now we use the cpfunc -d to copy all our aqua functions to the fish functions directory
cpfunc -d $AQUA__CLI_DIR
cpfunc -d $AQUA__FUNC_DIR
cpfunc -d $AQUA__UPDATE_DIR
