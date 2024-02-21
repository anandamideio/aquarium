#!/usr/bin/env fish

if type -q code
  set -l current_os (uname -s)
  set -l trueOS
  set -U vscodeSettingsPath

  # If current_os is Linux then the user config is at:
  # -- $HOME/.config/Code/User/settings.json
  # OR (If this is WSL/WSL2)
  # -- $HOME/mnt/c/Users/username/AppData/Roaming/Code/User/settings.json
  # If current_os is Darwin (MacOS) then the user config is at:
  # -- $HOME/Library/Application Support/Code/User/settings.json
  # So we need to try and detect where it is
  if test $current_os = "Linux"
    set vscodeSettingsPath $HOME/.config/Code/User/settings.json
    set trueOS (lsb_release -d | awk '{print $2}')
    if not test -f $vscodeSettingsPath
      set windows__username (cmd.exe /c "echo %USERNAME%" 2>/dev/null | tail -n 1 | tr -d '\r')
      set vscodeSettingsPath "/mnt/c/Users/"$windows__username"/AppData/Roaming/Code/User/settings.json"
      set trueOS "Windows via"
      set -a trueOS (uname -r | awk -F- '{print $4}')
    end
  else if test $current_os = "Darwin"
    set vscodeSettingsPath $HOME/Library/Application\ Support/Code/User/settings.json
    set trueOS "MacOS"
  end

  printf "You are running VSCODE from $trueOS\n"
  printf ""

  # If we still can't find the vscode settings file then we can't do anything
  if not test -f $vscodeSettingsPath
    printf "Could not find your vscode settings file. Please open vscode and try again"
    exit 1
  end

  set enableImages (jq -r '.["terminal.integrated.enableImages"]' $vscodeSettingsPath)
  set defaultProfile (jq -r '.["terminal.integrated.defaultProfile.linux"]' $vscodeSettingsPath)

  if not test "$enableImages" = "true"
    # Add "terminal.integrated.enableImages": true if it's not there or turn it on if it's off
    if not jq -e '.["terminal.integrated.enableImages"]' $vscodeSettingsPath > /dev/null
      echo "Adding terminal.integrated.enableImages to your vscode settings"
      jq '. + {"terminal.integrated.enableImages": true}' $vscodeSettingsPath | cache_pipe $vscodeSettingsPath
    else
      echo "Turning on terminal.integrated.enableImages in your vscode settings"
      jq '. + {"terminal.integrated.enableImages": true}' $vscodeSettingsPath | cache_pipe $vscodeSettingsPath
    end
  end

  if not test "$defaultProfile" = "fish"
    # Make fish the default shell in VSCODE ("terminal.integrated.defaultProfile.linux": "fish")
    if not jq -e '.["terminal.integrated.defaultProfile.linux"]' $vscodeSettingsPath > /dev/null
      echo "Setting terminal.integrated.defaultProfile.linux to fish in your vscode settings"
      jq '. + {"terminal.integrated.defaultProfile.linux": "fish"}' $vscodeSettingsPath | cache_pipe $vscodeSettingsPath
    else
      echo "Setting terminal.integrated.defaultProfile.linux to fish in your vscode settings"
      jq '. + {"terminal.integrated.defaultProfile.linux": "fish"}' $vscodeSettingsPath | cache_pipe $vscodeSettingsPath
    end
  end

  # remove the vscodeSettingsPath variable
  set -e vscodeSettingsPath
end


