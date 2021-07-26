#!/bin/bash

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

printf 'Are you sure? Type "uninstall Arnix" (all uppercase) to continue: '
tput sgr0
read REPLY
if [ "${REPLY}" != "UNINSTALL ARNIX" ]; then
    error "Input did not match"
    exit 1
fi

ls /arnix/generations | sort
question 'Which generation should be used?'
_generation="$answer"
[ -z "$answer" ] && \
    exit 1
if [ ! -d /arnix/generations/${_generation} ]; then
    error "Generation ${_generation} does not exist"
    exit 1
fi

log "Installing dependencies"
[ -n "$(command -v pacstrap)" ] && \
    pacman -S --noconfirm --needed --asdeps arch-install-scripts 1>/dev/null

tempsystempath="/tmp/temproot"
log "Installing temporary system to ${tempsystempath}"
mkdir -p ${tempsystempath}
mount -t tmpfs none ${tempsystempath}
pacstrap ${tempsystempath} base 1>/dev/null

log "Reverting changes (1/2)"
rm /usr/bin/arnixctl
rm /etc/pacman.d/hooks/0-arnix-create-generation.hook
mv /etc/os-release.arnixsave /etc/os-release

log "Pivoting to ${tempsystempath}"
mount --make-rprivate /
mkdir ${tempsystempath}/oldroot
pivot_root ${tempsystempath} ${tempsystempath}/oldroot
mount -t proc none /proc # required for umount to work

log "Deactivating generation ${generation}"
for i in ${_dirs}; do
    umount -l /oldroot/$i # lazy unmount because A: this works B: we restore the directories anyways
done
rm -rf /oldroot/boot/*

log "Reverting changes (2/2)"
rm /oldroot/usr/bin # remove symlink to arnix
for i in ${_dirs}; do
    mv /oldroot/arnix/generations/${_generation}/$i/* /oldroot/$i
done
mv /oldroot/arnix/generations/${_generation}/boot/* /oldroot/boot
rm -rf /oldroot/arnix

log "Pivoting back"
mount --make-rprivate /
pivot_root /oldroot /oldroot${tempsystempath}
umount -R ${tempsystempath}
rmdir ${tempsystempath}

log 'Arnix was successfully uninstalled. You may continue using your system'