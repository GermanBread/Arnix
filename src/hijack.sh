#!/bin/bash
error() {
    printf "$(tput setaf 1)[!] ERROR:$(tput sgr0) $*\n"
}
log() {
    printf "$(tput setaf 5)[!] INFO:$(tput sgr0) $*\n"
}

if [ $(id -u) -ne 0 ]; then
    error "This script needs to run as root"
    exit 1
fi
if [ -z $(command -v pacman) ]; then
    error "This script only runs on Arch Linux (or Arch-based as long as it has systemd)"
    exit 1
fi
if [ ! -d /var/lib/systemd ]; then
    error "As of now only systemd is supported"
    exit 1
fi
if [ -d /arnix ]; then
    error "Arnix is already installed, use 'arnixctl update' instead"
    exit 1
fi
if [ ! -e files ]; then
    error "Setup files were not found ... (did you not cd into the script's directory?)"
    exit 1
fi

tput setaf 1
cat << END
╭─────────────────────────────────────────────╮
│                                             │
│                 ╶ WARNING ╴                 │
│                                             │
│  THIS SCRIPT HIJACKS YOUR CURRENT INSTALL   │
│                                             │
│  THE OPERATIONS PERFORMED ARE NOT INTENDED  │
│   TO BE REVERSIBLE! RUN AT YOUR OWN RISK!   │
│                                             │
│           ARNIX IS ALSO IN ALPHA,           │
│      ONLY USE IT IN A VIRTUAL MACHINE       │
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

source files/arnix.conf

log "Installing dependencies"
pacman -S --noconfirm --needed arch-install-scripts

# Now we set up a simple system
# Probably overengineered but worth it
tempsystempath="/tmp/temproot"
log "Installing temporary system to ${tempsystempath}"
mkdir -p ${tempsystempath}
mount -t tmpfs none ${tempsystempath}
pacstrap ${tempsystempath} base busybox

log "Installing Arnix (1/2)"
mkdir -p /arnix/{bin,etc}
cp files/busybox /arnix/bin
cp files/init /arnix/bin
cp files/arnixctl /arnix/bin
cp files/arnix.conf /arnix/etc
chmod 755 -R /arnix/bin

log "Pivoting to ${tempsystempath}"
mount --make-rprivate /
mkdir ${tempsystempath}/oldroot
pivot_root ${tempsystempath} ${tempsystempath}/oldroot

log "Creating generation 1"
mkdir -p /oldroot/arnix/generations/1
ln -sr /oldroot/arnix/generations/1 /oldroot/arnix/generations/current
_ifs=$IFS
IFS=' ' # POSIX standard does not have arrays
for i in ${_dirs}; do
    mkdir -p /oldroot/arnix/generations/1/$i
    mv /oldroot/$i/* /oldroot/arnix/generations/1/$i
done
IFS=$_ifs
unset _ifs

log "Installing Arnix (2/2)"
mkdir -p /oldroot/usr/bin
ln -sr /oldroot/arnix/bin/busybox /oldroot/usr/bin/sh
ln -sr /oldroot/arnix/bin/busybox /oldroot/usr/bin/echo
ln -sr /oldroot/arnix/bin/busybox /oldroot/usr/bin/mount
ln -sr /oldroot/arnix/bin/busybox /oldroot/usr/bin/readlink
ln -sr /oldroot/arnix/bin/init    /oldroot/usr/bin/init

log "Activating generation 1"
for i in ${_dirs}; do
    mount --bind /oldroot/arnix/generations/1/$i /oldroot/$i
done

log "Pivoting back"
mount --make-rprivate /
pivot_root /oldroot /oldroot${tempsystempath}
umount ${tempsystempath}
rmdir ${tempsystempath}

log 'Arnix was installed successfully. You may continue using your system'