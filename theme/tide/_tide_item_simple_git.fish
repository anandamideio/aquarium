function _tide_item_simple_git
    set -l _SIMPLE_GIT_BRANCH_NAME
    

    if not set -q _tide_location_color
        # For some reason this fixes the location color sometimes causing the text to dissapear
        set _tide_location_color (set_color white)
    end

    if not set -q _SIMPLE_GIT_ICON
        set -Ux _SIMPLE_GIT_ICON $_tide_location_color\uf1d3
    end

    # Check if we are in a git repository (suppress it returning to stdout)
    if git rev-parse --is-inside-work-tree --quiet >/dev/null   2>&1
        # Try to get the current branch name
        if test -n (git branch --show-current)
            set _SIMPLE_GIT_BRANCH_NAME (git branch --show-current)
        end
        
        # Check if the repository is dirty
        # Check for staged, unstaged, and untracked changes
        # Check for staged, unstaged, untracked changes, and conflicts
        set -l stat (git status --porcelain)
        if string match -qr '^[ADMR].' $stat
            set -g tide_git_bg_color $tide_git_bg_color_unstable
        else if string match -qr '^\?\?' $stat
            set -g tide_git_bg_color $tide_git_bg_color_unstable
        else if string match -qr '^UU' $stat
            set -g tide_git_bg_color $tide_git_bg_color_urgent
        else
            # Check if the current branch is ahead or behind the upstream branch
            set -l ahead_behind (git rev-list --count --left-right @{upstream}...HEAD  2>/dev/null)
            if string match -qr '^\d+\t\d+' $ahead_behind
                set -g tide_git_bg_color $tide_git_bg_color_unstable
            else
                set -g tide_git_bg_color $tide_git_bg_color_clean
            end
        end

        # Set the text color
        set -l location $_tide_location_color$_SIMPLE_GIT_BRANCH_NAME

        # Print the git item
        _tide_print_item git "$_SIMPLE_GIT_ICON $location"
    end
end
