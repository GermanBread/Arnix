#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    echo "rm -rf /arnix/generations/${_next_generation}" > /arnix/etc/init-hooks/pre-undo_new_generation.hook
    echo "rm -f /arnix/etc/init-hooks/pre-undo_new_generation.hook" >> /arnix/etc/init-hooks/pre-undo_new_generation.hook
    
    log "Creating new generation ${_next_generation}"
    log "Cloning generation ${_current_generation}"
    
    rm -rf /arnix/generations/${_next_generation}
    cp -al /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}
    rm -f /arnix/generations/${_current_generation}/var/lib/pacman/db.lck 2>/dev/null # current because pacman will remove the lock in next

    rm -rf /arnix/generations/${_next_generation}/boot
    cp -a /boot /arnix/generations/${_next_generation}/boot
fi

if [[ $@ != '*nosymlink*' ]] 2>/dev/null || [ -z $@ ]; then
    ln -srfT /arnix/generations/${_next_generation} /arnix/generations/current
    ln -srfT /arnix/generations/${_next_generation} /arnix/generations/latest

    rm /arnix/etc/init-hooks/pre-undo_new_generation.hook
fi
if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    log "Activating generation ${_next_generation}"
    for i in ${_dirs}; do
        /arnix/bin/busybox umount -l /$i
        /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
    done
fi