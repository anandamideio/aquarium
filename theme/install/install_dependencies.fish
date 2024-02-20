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

# Install any missing ubuntu software, setting up shortcuts, virtuals, and PATHs
print_separator "🔍 Checking for missing software, installing if needed 🔍"
installs bat fd-find chafa jq glow neofetch

# Check if fzf is installed
if not type -q fzf
  print_separator "🔍 Installing fzf 🔍"
  git clone --depth  1 https://github.com/junegunn/fzf.git ~/.cache/fzf
  yes | ~/.cache/fzf/install
else
  # Get the installed version of fzf
  set -l fzf_version (fzf --version | string split ' ')[1]

  # Compare the version with "0.46.1"
  if not string match -q '*0.46.1*' $fzf_version
    print_separator "🔍 Updating fzf 🔍"
    # Check if it was installed in cache and if so pull and rebuild
    if test -d ~/.cache/fzf
      cd ~/.cache/fzf
      git pull
      yes | ~/.cache/fzf/install
    else 
      # If it wasn't installed in cache, install it in cache
      git clone --depth  1 https://github.com/junegunn/fzf.git ~/.cache/fzf
      yes | ~/.cache/fzf/install
    end
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
