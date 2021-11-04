#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

echo -ne '\033[35m'
cat << splash

          :::     :::::::::  ::::    ::: ::::::::::: :::    ::: 
       :+: :+:   :+:    :+: :+:+:   :+:     :+:     :+:    :+:  
     +:+   +:+  +:+    +:+ :+:+:+  +:+     +:+      +:+  +:+    
   +#++:++#++: +#++:++#:  +#+ +:+ +#+     +#+       +#++:+      
  +#+     +#+ +#+    +#+ +#+  +#+#+#     +#+      +#+  +#+      
 #+#     #+# #+#    #+# #+#   #+#+#     #+#     #+#    #+#      
###     ### ###    ### ###    #### ########### ###    ###

splash
echo -ne '\033(B\033[m'

_option() {
    echo -e "\033[35marnixctl $1\033(B\033[m - \033[1m$2\033(B\033[m"
}

case $1 in
    status)
        echo 'Created by https://github.com/GermanBread'
        echo
        echo "Active generation: $(readlink /arnix/generations/current)"
        echo
        echo "Arnix branch: ${_branch_preset}"
        echo "Arnix version: ${_arnix_version}"
        echo "Arnix update source (tarball): ${_update_source_tarball}"
        echo "Arnix update source (sha1sum): ${_update_source_checksum}"
    ;;
    changelog)
        less -~N /arnix/var/changelog.txt
    ;;
    edit)
        /arnix/bin/edit-config.sh
    ;;
    branch)
        /arnix/bin/change-branch.sh
    ;;
    update)
        /arnix/bin/update-arnix.sh "$2"
    ;;
    create)
        /arnix/bin/create-generation.sh
    ;;
    switch)
        /arnix/bin/rollback.sh
    ;;
    delete)
        /arnix/bin/delete-generation.sh
    ;;
    uninstall)
        /arnix/bin/revert-hijack.sh
    ;;
    *)
        _option 'help     ' ' this menu'
        _option 'status   ' ' info about Arnix'
        _option 'changelog' ' view latest changelog'
        _option 'edit     ' " edit Arnix's configuration"
        _option 'branch   ' ' select update branch'
        _option 'update   ' " update Arnix's files"
        _option 'create   ' ' create a new generation'
        _option 'switch   ' ' switch to any generation'
        _option 'delete   ' ' delete a generation'
        _option 'uninstall' ' revert hijack'
    ;;
esac