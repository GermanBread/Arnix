#!/bin/bash
source /arnix/bin/shared.sh
check_for_action_requirements

printf 'Are you sure? Type "uninstall Arnix" (all uppercase) to continue: '
tput sgr0
read REPLY
if [ "${REPLY}" != "UNINSTALL ARNIX" ]; then
    error "Input did not match"
    exit 1
fi

ls /arnix/generations
question 'Which generation should be used (none for current)?'
_generation="$answer"
[ -z "$answer" ] && \
    _generation="current"
if [ ! -d /arnix/generations/${_generation} ]; then
    error "Generation ${_generation} does not exist"
    exit 1
fi

log "Installing dependencies"
pacman -S --noconfirm --needed arch-install-scripts 1>/dev/null

tempsystempath="/tmp/temproot"
log "Installing temporary system to ${tempsystempath}"
mkdir -p ${tempsystempath}
mount -t tmpfs none ${tempsystempath}
pacstrap ${tempsystempath} base 1>/dev/null

log "Reverting changes (1/2)"
mv /etc/os-release.arnixsave /etc/os-release
rm /usr/bin/arnixctl

log "Pivoting to ${tempsystempath}"
mount --make-rprivate /
mkdir ${tempsystempath}/oldroot
pivot_root ${tempsystempath} ${tempsystempath}/oldroot

log "Deactivating generation ${generation}"
for i in ${_dirs}; do
    umount /oldroot/$i
    rmdir /oldroot/$i
done

log "Reverting changes (2/2)"
rm -r /oldroot/usr
rm -r /oldroot/arnix
for i in ${_dirs}; do
    mv /oldroot/generations/${_generation}/$i /oldroot/$i
done

log "Pivoting back"
mount --make-rprivate /
pivot_root /oldroot /oldroot${tempsystempath}
umount ${tempsystempath}
rmdir ${tempsystempath}

log 'Arnix was successfully uninstalled. You may continue using your system'