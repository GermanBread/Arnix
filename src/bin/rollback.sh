#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

ls /arnix/generations
question 'Which generation should be used (leave empty for current)?'
_generation="$answer"
[ -z "$answer" ] && \
    _generation="current"
if [ ! -d /arnix/generations/${_generation} ]; then
    error "Generation ${_generation} does not exist"
    exit 1
fi

log "Activating generation ${_generation}"
ln -srfT /arnix/generations/${_generation} /arnix/generations/current
for i in ${_dirs}; do
    /arnix/bin/busybox umount -l /$i
    /arnix/bin/busybox mount --bind /arnix/generations/${_generation}/$i /$i
done

log "Rollback to generation ${_generation} completed successfully"