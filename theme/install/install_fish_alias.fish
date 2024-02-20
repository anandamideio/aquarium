#!/usr/bin/env fish

# If we don't have our neofetch alias yet lets add it
if not type -q whatami
  print_separator "🌐 Adding a sence of self (whatami) 🌐"
  alias whatami="neofetch"
  funcsave whatami
end
