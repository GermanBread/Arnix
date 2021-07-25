#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

if [ -d /arnix/merge ]; then
    error 'There are unmerged files in /arnix/merge'
    error 'Delete /arnix/merge when all files are merged / discarded'
    exit 1
fi

log "Installing dependencies"
[ -z "$(command -v wget)" ] && \
    pacman -S --noconfirm --needed --asdeps wget 1>/dev/null
[ -z "$(command -v gunzip)" ] && \
    pacman -S --noconfirm --needed --asdeps gzip 1>/dev/null
[ -z "$(command -v tar)" ] && \
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
mkdir -p /arnix/merge/etc
cp -a bin/* /arnix/bin
cp -a etc/os-release /arnix/etc/os-release
cp -a etc/0-arnix.hook /arnix/etc/0-arnix.hook
cp -a etc/arnix.conf /arnix/merge/etc/arnix.conf
cd /arnix/
cat /tmp/arnix-update/changelog.txt
rm -r /tmp/arnix-update

warning 'Manual intervention is required - files need to be merged'
warning '/arnix/merge/etc/arnix.conf -> /arnix/etc/arnix.conf'
warning 'Delete /arnix/merge when you are done'