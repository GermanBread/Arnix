#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

log "Installing dependencies"
[ -z $(command -v wget) ] && \
    pacman -S --noconfirm --needed --asdeps wget 1>/dev/null
[ -z $(command -v gunzip) ] && \
    pacman -S --noconfirm --needed --asdeps gzip 1>/dev/null
[ -z $(command -v tar) ] && \
    pacman -S --noconfirm --needed --asdeps tar 1>/dev/null

log "Downloading update for branch '${_branch_preset}', URL '${_update_source}'"
mkdir -p /tmp/arnix-update
cd /tmp/arnix-update
wget -qq "${_update_source}" -O bootstrap.tar.gz
if [ $? -ne 0 ]; then
    error 'Unable to download update'
    exit 1
fi
gunzip bootstrap.tar.gz
tar xf bootstrap.tar

rm -rf /arnix/merge
mkdir -p /arnix/merge
cp -a bin/* /arnix/bin
cp -a etc/os-release /arnix/etc
cp -a etc/0-arnix.hook /arnix/etc
cp -a etc/arnix.conf /arnix/merge/etc
cd /arnix/
rm -r /tmp/arnix-update

warning 'Manual intervention is required - files need to be merged'
warning '/arnix/merge/etc/arnix.conf -> /arnix/etc/arnix.conf'