#!/usr/bin/env fish

# Directories
set -Ux AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

# This script is used to uninstall oh-my-fish if it is installed
# Test if OMF_PATH is set and if omf is installed
if test -z $OMF_PATH; or not type -q omf
  return
end

# Since we are about to uninstall OMF lets backup a list of the plugins the had installed
set omfPlugins (omf list)
if not test -z $omfPlugins
  # Lets write that to $AQUARIUM_INSTALL_DIR/bak/omf_plugins.txt
  mkdir -p $AQUARIUM_INSTALL_DIR/bak
  echo $omfPlugins > $AQUARIUM_INSTALL_DIR/bak/omf_plugins.txt
end

# If they had the nvm plugin installed, we should check which version of node they had active
if string match -q "nvm" $omfPlugins
  set -l nvmVersion (nvm current)
  if not test -z $nvmVersion
    # Lets write that to $AQUARIUM_INSTALL_DIR/bak/nvm_version.txt
    echo $nvmVersion > $AQUARIUM_INSTALL_DIR/bak/nvm_version.txt

    # If the version is newer than 16.9 we should check if they had corepack enabled
    if type -q corepack; and type -q yarn
      # Since they are using yarn / corepack lets use yarn to get their global packages
      set -l yarnGlobalPackages (yarn global list)
      if not test -z $yarnGlobalPackages
        # Lets write that to $AQUARIUM_INSTALL_DIR/bak/yarn_global_packages.txt
        echo $yarnGlobalPackages > $AQUARIUM_INSTALL_DIR/bak/yarn_global_packages.txt
      end

    else # They are using npm
      # Lets use npm to get their global packages
      set -l npmGlobalPackages (npm list -g --depth=0)
      if not test -z $npmGlobalPackages
        # Lets write that to $AQUARIUM_INSTALL_DIR/bak/npm_global_packages.txt
        echo $npmGlobalPackages > $AQUARIUM_INSTALL_DIR/bak/npm_global_packages.txt
      end
    end
  end
end

# Patch ohmyfish to accept -y as a flag
set -l omfInstallFilePath $OMF_PATH/bin/install

# Check if the file exist, if so back it up
if test -e $omfInstallFilePath
  bak $omfInstallFilePath 5
end

# Overwrite the original file with our new one
cp $AQUARIUM_INSTALL_DIR/theme/ohmyfish/install.fish $omfInstallFilePath

# Patch the function that calls the install script to always pass the -y as a flag
cpfunc $AQUARIUM_INSTALL_DIR/theme/ohmyfish/omf.destroy.fish

# remove ohmyfish since fisher handles ohmyfish plugins, and it's better made
set -l exit_status (omf.destroy)

# Check the exit status
if test $status -ne 0
  echo "Oh My Fish uninstallation failed."
  return 1 # Fail out early if we can't uninstall ohmyfish
end
