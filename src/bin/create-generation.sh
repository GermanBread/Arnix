#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

log "Creating new generation ${_next_generation}"
_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

log "Cloning generation ${_current_generation}"
rm -rf /arnix/generations/${_next_generation}
cp -al /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}

log "Activating generation ${_next_generation}"
ln -srfT /arnix/generations/${_next_generation} /arnix/generations/current
for i in ${_dirs}; do
    /arnix/bin/busybox umount -l /$i
    /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
done