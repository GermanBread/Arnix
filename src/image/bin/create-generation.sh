#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    echo "echo \"update got interrupted - undoing changes\"" > /arnix/var/init-hooks/pre-undo_new_generation.hook
    echo "rm -rf /arnix/generations/${_next_generation}" > /arnix/var/init-hooks/pre-undo_new_generation.hook
    echo "rm -f /arnix/var/init-hooks/pre-undo_new_generation.hook" >> /arnix/var/init-hooks/pre-undo_new_generation.hook
    
    log "Creating new generation ${_next_generation}"
    log "Cloning generation ${_current_generation}"
    
    rm -rf /arnix/generations/${_next_generation}
    
    cp -al /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}
fi

if [[ $@ != '*nosymlink*' ]] 2>/dev/null || [ -z $@ ]; then
    cp -a /boot /arnix/generations/${_current_generation}/boot
    
    ln -srfnT /arnix/generations/${_next_generation} /arnix/generations/current
    ln -srfnT /arnix/generations/$(ls /arnix/generations | sort -g | tail -n 1) /arnix/generations/latest

    rm /arnix/var/init-hooks/pre-undo_new_generation.hook
fi
if [[ $@ != '*nocopy*' ]] 2>/dev/null || [ -z $@ ]; then
    log "Activating generation ${_next_generation}"
    for i in ${_dirs}; do
        /arnix/bin/busybox umount -l /$i
        # Should run once but whatever
        ln -srfnT /arnix/generations/${_next_generation}/usr/share/grub /usr/share/grub
        /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
    done
    # remove db lock
    rm -f /arnix/generations/${_current_generation}/var/lib/pacman/db.lck 2>/dev/null
fi