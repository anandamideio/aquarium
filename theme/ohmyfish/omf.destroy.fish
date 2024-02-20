function omf.destroy --description 'Remove Oh My Fish'
    # Run the uninstaller
    fish "$OMF_PATH/bin/install" --uninstall-silent "--path=$OMF_PATH" "--config=$OMF_CONFIG"

    sleep 2

    # Immediately check the exit status of the last command
    if not type -q omf
        echo "Oh My Fish has been removed"
        return  0
    else
        echo "Oh My Fish could not be removed"
        return  1
    end
end
