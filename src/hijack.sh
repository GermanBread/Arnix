#!/bin/bash

# fake error
error() {
    printf "$(tput setaf 1)[!] ERROR:$(tput sgr0) $*\n"
}

if [ $(id -u) -ne 0 ]; then
    error "This script needs to run as root"
    exit 1
fi
if [ -z "$(command -v pacman)" ]; then
    error "This script only runs on Arch Linux (or Arch-based as long as it has systemd)"
    exit 1
fi
if [ -z "$(command -v systemctl)" ]; then
    error "As of now only systemd is supported"
    exit 1
fi
if [ -d /arnix ]; then
    error "Arnix is already installed, use 'arnixctl update' instead"
    exit 1
fi
if [ ! -e etc ] && [ ! -e bin ]; then
    error "Setup files were not found ... (did you not cd into the script's directory?)"
    exit 1
fi

source bin/shared.sh
source etc/arnix.conf

tput setaf 1
cat << END
╭─────────────────────────────────────────────╮
│                                             │
│                 ╶ WARNING ╴                 │
│                                             │
│  THIS SCRIPT HIJACKS YOUR CURRENT INSTALL   │
│                                             │
│           ARNIX IS ALSO IN ALPHA,           │
│      ONLY USE IT IN A VIRTUAL MACHINE       │
│                                             │
│    EVEN THOUGH THE HIJACK IS REVERSIBLE,    │
│    DO NOT RELY ON IT. MAKE A FULL SYSTEM-   │
│   BACKUP IF YOU TRY THIS ON A REAL MACHINE  │
│                                             │
╰─────────────────────────────────────────────╯
END
tput setaf 15
printf 'Type "I understand the risk" (all uppercase) to continue: '
tput sgr0
read REPLY
if [ "${REPLY}" != "I UNDERSTAND THE RISK" ]; then
    error "Input did not match"
    exit 1
fi

log "Installing dependencies"
[ -n $(command -v pacstrap) ] && \
    pacman -S --noconfirm --needed --asdeps arch-install-scripts 1>/dev/null
[ -z $(command -v tput) ] && \
    pacman -S --noconfirm --needed --asdeps ncurses 1>/dev/null

# Now we set up a simple system
# Probably overengineered but worth it
tempsystempath="/tmp/temproot"
log "Installing temporary system to ${tempsystempath}"
mkdir -p ${tempsystempath}
mount -t tmpfs none ${tempsystempath}
pacstrap ${tempsystempath} base 1>/dev/null
if [ $? -ne 0 ]; then
    error "'pacstrap' command errored, cannot continue safely. Is your system up to date?"
    exit 1
fi

log "Installing Arnix (1/2)"
mkdir -p /arnix
cp -r bin /arnix
cp -r etc /arnix

ln -sr /arnix/bin/arnixctl /usr/bin/arnixctl
mv /etc/os-release /etc/os-release.arnixsave
ln -sr /arnix/etc/os-release /etc/os-release
mkdir -p /etc/pacman.d/hooks/
ln -sr /arnix/etc/0-arnix-create-generation.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
chmod 755 -R /arnix/bin
chmod 755 /usr/bin/arnixctl

log "Pivoting to ${tempsystempath}"
mount --make-rprivate /
mkdir ${tempsystempath}/oldroot
pivot_root ${tempsystempath} ${tempsystempath}/oldroot

log "Creating generation 1"
mkdir -p /oldroot/arnix/generations/1
ln -sr /oldroot/arnix/generations/1 /oldroot/arnix/generations/current
ln -sr /oldroot/arnix/generations/1 /oldroot/arnix/generations/latest
_ifs=$IFS
IFS=' ' # POSIX standard does not have arrays
for i in ${_dirs}; do
    mkdir -p /oldroot/arnix/generations/1/$i
    mv /oldroot/$i/* /oldroot/arnix/generations/1/$i
done
IFS=$_ifs
unset _ifs
cp -a /oldroot/boot /oldroot/arnix/generations/1/boot

log "Installing Arnix (2/2)"
ln -sr /oldroot/arnix/bin /oldroot/usr/bin
# Just to get systemd working
ln -sr /oldroot/arnix/etc/os-release /oldroot/etc/os-release
# GRUB themes
mkdir -p /oldroot/usr/share
ln -srfT /oldroot/arnix/generations/current/usr/share/grub /oldroot/usr/share/grub

log "Activating generation 1"
for i in ${_dirs}; do
    mount --bind /oldroot/arnix/generations/1/$i /oldroot/$i
done

log "Pivoting back"
mount --make-rprivate /
pivot_root /oldroot /oldroot${tempsystempath}
umount -R ${tempsystempath}
rmdir ${tempsystempath}

log 'Arnix was successfully installed. You may continue using your system'
log "Arnix can now be managed with 'arnixctl'!"