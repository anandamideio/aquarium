#!/usr/bin/env fish

# Check if the $AQUARIUM_INSTALL_DIR is set
if test -z "$AQUARIUM_INSTALL_DIR"
  set -Ux AQUARIUM_INSTALL_DIR "$HOME/.aquarium"
end

## Check if we have any of the files that mark us needing 
## to reinstall a node version / global packages:
if not test -f "$AQUARIUM_INSTALL_DIR/bak/nvm_version.txt"
  if type -q node
    ## Check laltest node version
    # Returns something like:
    #  ▶   v21.6.2 latest ✓
    # So we will string match so we just have the version
    set aqua__latest_node_version (string match -r "[0-9]+\.[0-9]+\.[0-9]+" (nvm ls-remote | tail -n 1));
    # Lets start a match after the v and check if the current node version is the same as the latest
    set aqua__current_node_version (string match -r "[0-9]+\.[0-9]+\.[0-9]+" (node -v))

    if test "$aqua__latest_node_version" != "$aqua__current_node_version"
      if read_confirm "Do you want to install the latest node version ($aqua__latest_node_version)? (y/n)"
        print_separator "Installing latest node version"
        nvm install latest
        nvm use latest
        mkdir -p "$AQUARIUM_INSTALL_DIR/bak"
        nvm current > "$AQUARIUM_INSTALL_DIR/bak/nvm_version.txt"
        return
      end
      return
    end
  else
    nvm install latest
    nvm use latest
    mkdir -p "$AQUARIUM_INSTALL_DIR/bak"
    nvm current > "$AQUARIUM_INSTALL_DIR/bak/nvm_version.txt"
  end
else
  # Will be in the format of "v12.18.3" but we want "12.18.3"
  set -U aqua__nvm_version_file (cat $AQUARIUM_INSTALL_DIR/bak/nvm_version.txt | string sub -s 2)
  
  # As long as aqua__nvm_version_file is now num.num.num, we can use it (Ex 12.18.3)
  if not string match -r "[0-9]+\.[0-9]+\.[0-9]+" $aqua__nvm_version_file
    echo "Invalid nvm version file. Installing latest node version"
    nvm install latest
    nvm use latest
    nvm current > "$AQUARIUM_INSTALL_DIR/bak/nvm_version.txt"
  end
end

# Turns out we just use `yarn dlx` to install global packages now temp so this is not needed
# Check if we have any global packages to install
# if test -f "$AQUARIUM_INSTALL_DIR/bak/yarn_global_packages.txt"
#   print_separator "Installing yarn global packages"
#   ## This file will look something like:
#   # yarn global v1.22.19
#   # info "create-solid@0.4.10" has binaries:
#   #   - create-solid
#   # info "create-vite@4.4.1" has binaries:
#   #   - create-vite
#   #   - cva
#   # info "create-vite-express@0.0.5" has binaries:
#   #   - create-vite-express
#   # Done in 0.09s.
#   #
#   # We want to extract the package names and install them, luckilyu we just need the names in quotes
#   set -U aqua__yarn_global_list_file "$AQUARIUM_INSTALL_DIR/bak/yarn_global_packages.txt"
#   set -U aqua__yarn_global_packages (cat $aqua__yarn_global_list_file | grep -oP "(?<=info \").*(?=\")")
#   for package in $aqua__yarn_global_packages
#     print_separator " Reinstalling $package globally for you"
#     yarn global add $package
#   end
# end

# set -U aqua__yarn_global_list_file "$AQUARIUM_INSTALL_DIR/bak/yarn_global_packages.txt"
# set -U aqua__npm_global_list_file "$AQUARIUM_INSTALL_DIR/bak/npm_global_packages.txt"



# # Unset the variables
# set -e aqua__nvm_version_file
# set -e aqua__yarn_global_list_file
# set -e aqua__npm_global_list_file
