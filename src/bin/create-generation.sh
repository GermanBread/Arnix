#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    echo "rm -rf /arnix/generations/${_next_generation}" > /arnix/etc/init-hooks/pre-undo_new_generation.hook
    echo "rm -f /arnix/etc/init-hooks/pre-undo_new_generation.hook" >> /arnix/etc/init-hooks/pre-undo_new_generation.hook
    
    log "Creating new generation ${_next_generation}"
    log "Cloning generation ${_current_generation}"
    
    umount -l /arnix/generations/${_next_generation} &>/dev/null
    rm -rf /arnix/generations/${_next_generation}
    rm -rf /arnix/generations/${_current_generation}/boot
    
    cp -al /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}

    rm -f /arnix/generations/${_next_generation}/var/lib/pacman/db.lck 2>/dev/null # current because pacman will remove the lock in next gen
    cp -a /boot /arnix/generations/${_current_generation}/boot

    makero /arnix/generations/${_current_generation}
fi

if [[ $@ != '*nosymlink*' ]] 2>/dev/null || [ -z $@ ]; then
    #cp -a /boot /arnix/generations/${_next_generation}/boot
    
    ln -srfnT /arnix/generations/${_next_generation} /arnix/generations/current
    ln -srfnT /arnix/generations/$(ls /arnix/generations | sort -g | tail -n 1) /arnix/generations/latest

    rm /arnix/etc/init-hooks/pre-undo_new_generation.hook
fi
if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    log "Activating generation ${_next_generation}"
    for i in ${_dirs}; do
        /arnix/bin/busybox umount -l /$i
        # Should run once but whatever
        ln -srfnT /arnix/generations/${_next_generation}/usr/share/grub /usr/share/grub
        /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
    done
fi