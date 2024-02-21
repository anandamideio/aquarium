#!/usr/bin/env fish

function aqua__update_fzf -d 'Update fzf, and install our key bindings'
  pushd ~/.cache/fzf
  git pull
  yes | ./install
  popd

  # Now we need to see if the default fzf_key_bindings function symlink got added to our fish functions folder, and if so, unlink it
  if test -L ~/.config/fish/functions/fzf_key_bindings.fish
    unlink ~/.config/fish/functions/fzf_key_bindings.fish
    sed -i '/fzf_key_bindings/d' ~/.config/fish/functions/fish_user_key_bindings.fish
  end

  set -l fzf_key_bindings_file $AQUARIUM_INSTALL_DIR/theme/fzf/fzf_key_bindings.fish

  # And instead lets just run our key bindings function
  fish -c $fzf_key_bindings_file
end
