#!bin/busybox sh

alias ln='bin/toybox ln'

# will get overwritten by the one in shared.sh
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}

if [ $(id -u) -ne 0 ]; then
    error "This script needs to run as root"
    exit 1
fi
if [ -z "$(command -v pacman)" ]; then
    error "This script only runs on Arch Linux (or Arch-based as long as it has systemd)"
    exit 1
fi
if [ -d /etc/nixos ]; then
    error "You're already using a distro with a generations system"
    exit 1
fi
if [ -d /arnix ]; then
    error "Arnix is already installed, use 'arnixctl update' instead"
    exit 1
fi
if [ ! -d /var/lib/systemd ]; then
    error "As of now only systemd is supported."
    exit 1
fi
if [ ! -e etc ] && [ ! -e bin ]; then
    error "Setup files were not found ... (did you not cd into the script's directory?)"
    exit 1
fi

source bin/shared.sh
source etc/arnix.conf

echo -e '\033[31m'
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
echo -e '\033[97m'
printf 'Type "I understand the risk" (all uppercase) to continue: '
echo -ne '\033(B\033[m'
read REPLY
if [ "${REPLY}" != "I UNDERSTAND THE RISK" ]; then
    error "Input did not match"
    exit 1
fi

log "Installing Arnix (1/2)"
mkdir -p /arnix
cp -r bin /arnix/bin
cp -r etc /arnix/etc

ln -sr /arnix/bin/arnixctl /usr/bin/arnixctl
mv -f /etc/os-release /etc/os-release.arnixsave
ln -sr /arnix/etc/os-release /etc/os-release
mkdir -p /etc/pacman.d/hooks/
ln -sr /arnix/etc/0-arnix-create-generation.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
ln -sr /arnix/etc/100-arnix-change-symlink.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
chmod 755 -R /arnix/bin
chmod 755 /usr/bin/arnixctl

log "Creating generation 1"
mkdir -p /arnix/generations/1
ln -sr /arnix/generations/1 /arnix/generations/current
ln -sr /arnix/generations/1 /arnix/generations/latest
_ifs=$IFS
IFS=' ' # POSIX standard does not have arrays
for i in ${_dirs}; do
    mkdir -p /arnix/generations/1/$i
    mv /$i/* /arnix/generations/1/$i
done
IFS=$_ifs
cp -a /boot /arnix/generations/1/boot

log "Installing Arnix (2/2)"
ln -sr /arnix/bin /usr/bin
# Just to get systemd in initrd working
ln -sr /arnix/etc/os-release /etc/os-release
# GRUB themes
mkdir -p /usr/share
ln -srfT /arnix/generations/current/usr/share/grub /usr/share/grub

log "Activating generation 1"
for i in ${_dirs}; do
    mount --bind /arnix/generations/1/$i /$i
done

log 'Arnix was successfully installed. You may continue using your system'
log "Arnix can now be managed with 'arnixctl'!"