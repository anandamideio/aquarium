#!/usr/bin/env fish

# If we don't have our neofetch alias yet lets add it
if not type -q whatami
  print_separator "🌐 Adding a sence of self (whatami) 🌐"
  alias whatami="neofetch"
  funcsave whatami
end

## We used to use the following exa aliases, so if they exist, lets remove them
# alias --save ll="exa -l -g --icons"
# alias --save lla="ll -a"
if functions -q ll
  print_separator "📂 Removing exa alias 📂"
  functions --erase ll
  functions --erase lla
end

# We replaced exa with lsd
# If we don't have our lsd aliases yet lets add them
if not functions -q lt
  print_separator "📂 Adding some color to our directories (lsd) 📂"
  alias ls="lsd"
  funcsave ls

  alias la='ls -a'
  funcsave la

  alias lla='ls -la'
  funcsave lla

  alias lt='ls --tree'
  funcsave lt

  alias ll="lsd -l"
  funcsave ll
end
