#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

printf 'Are you sure? Type "uninstall Arnix" (all uppercase) to continue: '
echo -ne '\033(B\033[m'
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

log "Reverting changes (1/2)"
rm /usr/bin/arnixctl
rm /etc/pacman.d/hooks/0-arnix-create-generation.hook
rm /etc/pacman.d/hooks/100-arnix-change-symlink.hook
mv /etc/os-release.arnixsave /etc/os-release

log "Deactivating generation ${generation}"
for i in ${_dirs}; do
    umount -l /$i # lazy unmount because A: this works B: we restore the directories anyways
done
rm -rf /boot/*

log "Reverting changes (2/2)"
rm -r /usr/* # revert symlinks in /usr
for i in ${_dirs}; do
    mv /arnix/generations/${_generation}/$i/* /$i
done
mv /arnix/generations/${_generation}/boot/* /boot
rm -rf /arnix

log 'Arnix was successfully uninstalled. You may continue using your system'