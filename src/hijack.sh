#!bin/busybox sh

# will get overwritten by the definitions in shared.sh
log() {
    printf "\033[35m[-] INFO:\033(B\033[m $*\n"
}
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
warning() {
    printf "\033[33m[=] WARNING:\033(B\033[m $*\n"
}

if [ $(id -u) -ne 0 ]; then
    error "This script needs to run as root"
    exit 1
fi
if [ -z "$(command -v pacman)" ]; then
    error "Only Arch and Arch-based are supported"
    exit 1
    warning "Only Arch and some Arch-based distros are tested. The hijack might or might not brick your distro. You also won't have automatic generations."
    log 'Press enter to continue'
    read
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
alias ln="$(pwd)/bin/toybox ln"
alias sha1sum="$(pwd)/bin/toybox sha1sum"

source etc/arnix.conf

echo -e '\033[31m'
cat << END
+                                                                                     +

                                - WARNING -

                    THIS SCRIPT HIJACKS YOUR CURRENT INSTALL!
            EVEN THOUGH THE HIJACK IS REVERSIBLE, DO NOT RELY ON IT.
          MAKE A FULL SYSTEM BACKUP IF YOU TRY THIS ON A REAL MACHINE

+                                                                                     +
END
echo -e '\033[97m'
printf 'Type "install Arnix" (all uppercase) to continue: '
echo -ne '\033(B\033[m'
read REPLY
if [ "${REPLY}" != "INSTALL ARNIX" ]; then
    error "Input did not match"
    exit 1
fi

log "Installing Arnix (1/2)"
mkdir -p /arnix
cp -r bin /arnix/bin
cp -r etc /arnix/etc
create_checksums /arnix/bin
create_checksums /arnix/etc
mkdir -p /arnix/etc/init-hooks

ln -sr /arnix/bin/arnixctl /usr/bin/arnixctl
mv -f /etc/os-release /etc/os-release.arnixsave
ln -sr /arnix/etc/os-release /etc/os-release

chmod 755 -R /arnix/bin
chmod 755 /usr/bin/arnixctl

# link package manager hooks here
if [ -n "$(command -v pacman)" ]; then
    mkdir -p /etc/pacman.d/hooks/
    ln -sr /arnix/etc/0-arnix-create-generation.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
    ln -sr /arnix/etc/100-arnix-change-symlink.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
fi

# Workaround for Ubuntu
mkdir -p /var/db

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