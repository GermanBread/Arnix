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