#!/usr/bin/env fish

# Now we should check if fisher is installed
if not type -q fisher
  print_separator "🎣 Installing Fisher 🎣"
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

  # Install fisher plugins
  if test -z (fisher list done)
    fisher install franciscolourenco/done # Get a notification when a long running command finishes
  end

  if test -z (fisher list spark)
    fisher install jorgebucaran/spark.fish # Sparklines for fish
  end

  if test -z (fisher list sponge)
    fisher install meaningful-ooo/sponge # If a command returns error, don't save it to our history
  end

  if test -z (fisher list nvm)
    fisher install jorgebucaran/nvm.fish # Node Version Manager
  end

  if test -z (fisher list bass)
    fisher install edc/bass # Use shell commands in fish
  end
end


# Install mdcat
if not type -q mdcat
  print_separator "📖 Installing mdcat 📖"
  mkdir -p ~/.cache/mdcat
  wget -P ~/.cache/mdcat https://github.com/swsnr/mdcat/releases/download/mdcat-2.1.1/mdcat-2.1.1-x86_64-unknown-linux-musl.tar.gz
  tar -xzf ~/.cache/mdcat/mdcat-2.1.1-x86_64-unknown-linux-musl.tar.gz -C ~/.cache/mdcat
  fish_add_path ~/.cache/mdcat/mdcat-2.1.1-x86_64-unknown-linux-musl/
end


# Add stuff for glow
if not type -q glow
  print_separator "🌟 Sourcing Glow 🌟"
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update
end

set aqua__base_dependencies build-essential procps curl file git bat chafa jq glow neofetch
set aqua__missing_dependencies
for package in $aqua__base_dependencies
  if not type -q $package
    set -a aqua__missing_dependencies $package
  end
end

if not test -z $aqua__missing_dependencies
  print_separator "🔍 Installing missing dependencies 🔍"
  installs $aqua__missing_dependencies
end

if not type -q fd
  print_separator "🔍 Installing fd-find 🔍"
  installs fd-find
end

# Check if fzf is installed
if not type -q fzf
  print_separator "🔍 Installing fzf 🔍"
  git clone --depth  1 https://github.com/junegunn/fzf.git ~/.cache/fzf
  yes | ~/.cache/fzf/install

  # Add an update alias to fish
  alias update_fzf="aqua__update_fzf"
  funcsave update_fzf

  # Now we need to see if the default fzf_key_bindings function symlink got added to our fish functions folder, and if so, unlink it
  if test -L ~/.config/fish/functions/fzf_key_bindings.fish
    unlink ~/.config/fish/functions/fzf_key_bindings.fish
  end

  set -l fzf_key_bindings_file $AQUARIUM_INSTALL_DIR/theme/fzf/fzf_key_bindings.fish

  # And instead lets just run our key bindings function
  fish -c $fzf_key_bindings_file

  alias update_fzf="aqua__update_fzf"
else
  # Get the installed version of fzf
  set -l fzf_version (fzf --version | string split ' ')[1]

  # Compare the version with "0.46.1"
  if not string match -q '*0.46.1*' $fzf_version
    print_separator "🔍 Updating fzf 🔍"
    aqua__update_fzf
  end
end

# Now we can install timg on their system from source
if not type -q timg
  print_separator "🖼️ Installing timg 🖼️"
  # Install dependencies
  installs cmake g++ pkg-config libgraphicsmagick++-dev libturbojpeg-dev libexif-dev libswscale-dev libdeflate-dev librsvg2-dev libcairo-dev
  installs libsixel-dev libavcodec-dev libavformat-dev libavdevice-dev libopenslide-dev libpoppler-glib-dev pandoc

  mkdir -p ~/.cache/timg
  curl -sL https://github.com/hzeller/timg/releases/download/v1.6.0/timg-v1.6.0-x86_64.AppImage -o ~/.cache/timg/timg-v1.6.0-x86_64.AppImage
  # Rename it to just timg.AppImage
  mv ~/.cache/timg/timg-v1.6.0-x86_64.AppImage ~/.cache/timg/timg.AppImage
  chmod +x ~/.cache/timg/timg.AppImage
  fish_add_path ~/.cache/timg/

  # Create a fish alias so we can use it as just timg instead timg.AppImage
  alias timg="~/.cache/timg/timg.AppImage"
  funcsave timg
end

# Now we need to install homebrew if it's not installed
if not type -q brew
  print_separator "🍺 Installing Homebrew 🍺"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add the brew command to our path
  fish -c 'set da_home (getent passwd (whoami) | cut -d: -f6); echo; echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> $da_home/.config/fish/config.fish'; and \
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Now we can install the missing brew packages
set aqua__brew_dependencies watchman lsd fx
set aqua__missing_brew_dependencies
for package in $aqua__brew_dependencies
  if not type -q $package
    set -a aqua__missing_brew_dependencies $package
  end
end

if not test -z $aqua__missing_brew_dependencies
  print_separator "🍺 Installing missing brew dependencies 🍺"

  for package in $aqua__missing_brew_dependencies
    brew install $package
  end
end
