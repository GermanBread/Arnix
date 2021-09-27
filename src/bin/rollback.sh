#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

ls /arnix/generations
question 'Which generation should be used?'
_generation="$answer"
[ -z "$answer" ] && \
    exit 1
if [ ! -d /arnix/generations/${_generation} ]; then
    error "Generation ${_generation} does not exist"
    exit 1
fi

log "Activating generation ${_generation}"
[ -e /arnix/generations/current ] && \
    makero /arnix/generations/current
ln -srfnT /arnix/generations/${_generation} /arnix/generations/current
umount -l /arnix/generations/${_generation}
for i in ${_dirs}; do
    umount -l /$i 2>/dev/null
    # Should run once but whatever
    ln -srfnT /arnix/generations/${_generation}/usr/share/grub /usr/share/grub
    mount --bind /arnix/generations/${_generation}/$i /$i
done
rm -rf /boot/*
cp -a /arnix/generations/${_generation}/boot/* /boot

log "Rollback to generation ${_generation} completed successfully"