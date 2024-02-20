#!/usr/bin/env fish

function backup_and_edit -d 'Backup a file (make a copy with .backup) and open the original in nano' -a file -d 'The file to edit' -a max_copies -d 'The maximum number of copies to keep'
    # Version Number
    set -l func_version "1.0.3"
    # Flag options
    set -l options "v/version" "h/help" "b/backup"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Backup and Edit"
        echo "Version: $func_version"
        echo "Usage: backup_and_edit [file]"
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -b, --backup  Only make a backup, don't open the file"
        return
    end

    # if they didn't give a file, show an error
    if not set -q file
        echo "You must provide a file to edit"
        return
    end

    # if the file doesn't exist, show an error
    if not test -e $file
        echo "$file does not exist, at least not where I'm looking"
        return
    end

    # if the file is a directory, show an error
    if test -d $file
        echo "The $file is a directory, what are you trying to do?"
        return
    end

    # if the file is a symlink, show an error
    if test -L $file
        echo "The file $file is a symlink, this is not supported, or safe come to think of it"
        return
    end

    # if the file is not readable, show an error
    if not test -r $file
        echo "$file is not readable, I can't edit it, sorry"
        return
    end

    # if the file is not writable, show an error
    if not test -w $file
        echo "$file is not writable, I can't edit it, sorry"
        return
    end

    # No more than 5 copies by default
    set -l MAX $max_copies || 5

    ## The behavior should go:
    # 1. If there is no backup, make one as .backup
    # 2. If there is a backup, but no number suffixed backup, the backup called `.backup` should be renamed to `.1.backup` and a new `.backup` should be created
    # 3. If there is a backup with a number, the number should be incremented and a new `.backup` should be created
    # 4. If there are more than the max the user passed (or 5) backups, the oldest should be deleted
    if test -e $file.backup
        # If there is a backup, but no number suffixed backup, the backup called `.backup` should be renamed to `.1.backup` and a new `.backup` should be created
        if not test -e $file.1.backup
            mv $file.backup $file.1.backup
            cp $file $file.backup
        else
            # If there is a backup with a number, the number should be incremented and a new `.backup` should be created
            if test -e $file.1.backup
                for i in (seq $MAX -1  1)
                    if test -e $file.$i.backup
                        # If we are at max, we need to delete the oldest
                        if test $i -eq $MAX
                            rm $file.$i.backup
                            break
                        end

                        # If we are above 1, we need to copy this backup to the next highest number
                        if test $i -gt 1
                            mv $file.$i.backup $file.($i + 1).backup
                        else
                            # If we are at 1, we need to make a new .backup
                            mv $file.backup $file.1.backup
                            cp $file $file.backup
                        end
                    end
                end
            end
        end
    else
        # If there is no backup, make one as .backup
        cp $file $file.backup
    end

    if set -q _flag_b
        echo "Backup of $file created as $file.backup, exiting"
        return 0
    else
        ## Then open the file in nano
        nano $file
    end
end
