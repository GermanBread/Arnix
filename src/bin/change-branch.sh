#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

log "Installing dependencies"
[ -z $(command -v tput) ] && \
    pacman -S --noconfirm --needed --asdeps ncurses 1>/dev/null
[ -z $(command -v sed) ] && \
    pacman -S --noconfirm --needed --asdeps sed 1>/dev/null

echo 'Select branch:'
echo '1 - stable'
echo '2 - unstable'
echo '3 - custom'
while ! [[ $_mode = [123] ]]; do
    tput sc
    read -n 1 _mode
    tput rc
done
echo

_escape() {
    echo $* | sed 's/\//\\\//gm'
}

case ${_mode} in 
    1)
        sed -Ei "s/_update_source=.+/_update_source=$(_escape 'https://github.com/germanbread/arnix/releases/latest/download/arnix-bootstrap.tar.gz')/" /arnix/etc/arnix.conf
        sed -Ei "s/_branch_preset=\w+/_branch_preset=stable/" /arnix/etc/arnix.conf
    ;;
    2)
        sed -Ei "s/_update_source=.+/_update_source=$(_escape 'https://raw.githubusercontent.com/GermanBread/Arnix/master/src/arnix-bootstrap.tar.gz')/" /arnix/etc/arnix.conf
        sed -Ei "s/_branch_preset=\w+/_branch_preset=unstable/" /arnix/etc/arnix.conf
    ;;
    3)
        # TOOD Test the URL
        sed -Ei "s/_branch_preset=\w+/_branch_preset=custom/" /arnix/etc/arnix.conf
    ;;
esac