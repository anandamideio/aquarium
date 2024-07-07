#!/usr/bin/env fish

# Check if they have git installed
if type -q git
    # Set up some git aliases
    set visual_checkout_definition '!fish -c \'function visual-checkout
        set selected_branch (git branch --all | string replace -r "^.*\\/" "" | sort | uniq | fzf --preview "git show --color=always --stat {}" --preview-window="right:wrap")
        if test -n "$selected_branch"
            git switch "$selected_branch"
        else
            echo "No branch selected."
        end
    end; visual-checkout\''
    update_git_alias "visual-checkout" $visual_checkout_definition --silent

    set gone_definition '! git fetch -p && git for-each-ref --format "%(refname:short) %(upstream:track)" | awk \'$2 == "[gone]" {print $1}\' | xargs -r git branch -D'
    update_git_alias "gone" $gone_definition --silent
end

# Create a local variable to store the output of this grep
set -l gitColumnUI (git config --list | grep "column.ui")
if test -z $gitColumnUI
    git config --global column.ui
    git config --global branch.sort -committerdate
end
