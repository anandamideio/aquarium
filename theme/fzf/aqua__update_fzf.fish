#!/usr/bin/env fish

function aqua__update_fzf -d 'Update fzf, and install our key bindings'
  # Version Number
  set -l func_version "1.0.1"
  # Flag options
  set -l options "v/version" "h/help" "b/bindings"
  argparse -n installs $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    exit 0
  end

  # if they asked for help, show it
  if set -q _flag_help
    echo "Usage: aqua__update_fzf [options]"
    echo "Update fzf, and install our key bindings"
    echo ""
    echo "Options:"
    echo "  -v, --version  Show version number"
    echo "  -h, --help     Show this help"
    echo "  -b, --bindings Install our key bindings ONLY"
    return
  end

  if not set -q _flag_bindings
    pushd ~/.cache/fzf
    git pull
    yes | ./install
    popd
  end

  # Now we need to see if the default fzf_key_bindings function symlink got added to our fish functions folder, and if so, unlink it
  if test -L ~/.config/fish/functions/fzf_key_bindings.fish
    unlink ~/.config/fish/functions/fzf_key_bindings.fish
    sed -i '/fzf_key_bindings/d' ~/.config/fish/functions/fish_user_key_bindings.fish
  end

  cpfunc $AQUARIUM_INSTALL_DIR/theme/fzf/fzf_key_bindings.fish

  # And instead lets just run our key bindings function
  fzf_key_bindings

  print_separator "FZF Updated and Key Bindings Rebound"
end
