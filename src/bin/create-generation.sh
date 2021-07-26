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
rm -f /arnix/generations/${_current_generation}/var/lib/pacman/db.lck 2>/dev/null # current because pacman will remove the lock in next

rm -rf /arnix/generations/${_next_generation}/boot
cp -a /boot /arnix/generations/${_next_generation}/boot

log "Activating generation ${_next_generation}"
ln -srfT /arnix/generations/${_next_generation} /arnix/generations/current
ln -srfT /arnix/generations/${_next_generation} /arnix/generations/latest
for i in ${_dirs}; do
    /arnix/bin/busybox umount -l /$i
    /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
done