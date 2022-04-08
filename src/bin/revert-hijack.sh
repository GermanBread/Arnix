#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

echo -e '\033[97m'
printf 'While I (the dev) have managed to uninstall Arnix successfully, some distros became unbootable for reasons I have not figured out'
printf 'The main issue seems to be /boot.'
printf 'Uninstall at your own risk!'
printf 'Type "uninstall Arnix" (all uppercase):'
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

log "Deactivating generation ${generation}"
for i in ${_dirs}; do
    umount -l /$i # lazy unmount because A: this works B: we restore the directories anyways
done
rm -rf /boot/*

log "Reverting changes"
rm -r /usr/* # clean it first
for i in ${_dirs}; do
    mv /arnix/generations/${_generation}/$i/* /$i
done
cp -a /arnix/generations/${_generation}/boot/* /boot
# If the system uses GRUB with /boot/efi as esp
[ -e /boot/efi ] && \
    cp -a /arnix/generations/${_generation}/boot/efi/* /boot/efi
mv /etc/os-release.arnixsave /etc/os-release
rm /usr/bin/arnixctl

# delete package manager hooks here
# pacman
rm -f /etc/pacman.d/hooks/0-arnix-create-generation.hook
rm -f /etc/pacman.d/hooks/100-arnix-change-symlink.hook

log "Removing Arnix directory"
rm -rf /arnix

log 'Arnix was successfully uninstalled. You may continue using your system'