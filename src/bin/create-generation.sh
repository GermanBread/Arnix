#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

log "Creating new generation ${_next_generation}"
_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

log "Cloning generation ${_current_generation}"
cp -l /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}

log "Activating generation ${_next_generation}"
ln -srf /arnix/generations/${_next_generation} /arnix/generations/current
for i in ${_dirs}; do
    mount --bind /oldroot/arnix/generations/${_next_generation}/$i /oldroot/$i
done