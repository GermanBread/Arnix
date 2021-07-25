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
cp files/os-release /arnix/etc

ln -sr /arnix/bin/busybox /arnix/bin/'['
ln -sr /arnix/bin/busybox /arnix/bin/'[['
ln -sr /arnix/bin/busybox /arnix/bin/mount
ln -sr /arnix/bin/busybox /arnix/bin/sh
ln -sr /arnix/bin/busybox /arnix/bin/echo
ln -sr /arnix/bin/busybox /arnix/bin/egrep
ln -sr /arnix/bin/busybox /arnix/bin/cat
ln -sr /arnix/bin/busybox /arnix/bin/readlink
ln -sr /arnix/bin/arnixctl /usr/bin/arnixctl
rm /etc/os-release
ln -sr /arnix/etc/os-release /etc/os-release
chmod 755 -R /arnix/bin
chmod 755 /usr/bin/arnixctl

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
ln -sr /oldroot/arnix/bin /oldroot/usr/bin
mkdir -p /oldroot/var/{lib,run}
# Just to get systemd working
ln -sr /oldroot/arnix/generations/current/var/lib/systemd /oldroot/var/lib/systemd
ln -sr /oldroot/arnix/etc/os-release /oldroot/etc/os-release

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