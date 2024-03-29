#!/usr/bin/env false

FILE_ROOT=".." # can be overwritten

unattended_install=false

for i in $@; do
    case $i in
        --unattended)
            unattended_install=true
        ;;
        --src-root=*)
            FILE_ROOT=${i##*=}
        ;;
        --help)
cat << EOF
--help
--unattended: Install Arnix automatically
--src-root: Tell the hijack script where to locate the system image (dir should contain directories called "installer" and "image")
EOF
            exit 0
        ;;
    esac
    shift
done

# need to be here to reflect potential changes to $FILE_ROOT
IMAGE_ROOT="$FILE_ROOT/image"
INSTALLER_ROOT="$FILE_ROOT/installer"

# will get overwritten by the definitions in shared.sh
log() {
    printf "\033[35m[-] INFO:\033(B\033[m $@\n"
}
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $@\n"
}
warning() {
    printf "\033[33m[=] WARNING:\033(B\033[m $@\n"
}

if [ $(id -u) -ne 0 ]; then
    error "This script needs to run as root"
    exit 1
fi
if [ -z "$(command -v pacman)" ]; then
    warning "You are about to hijack a non-pacman-based distro. The hijack might or might not brick your distro. You also won't have automatic generations."
    warning "I tested Kubuntu, Debian, a modified install of Pop!OS and Kali. Debian's GRUB theme was broken after after the hijack, otherwise it booted fine. Continue at your own risk!"
    log 'Press enter to continue'
    read
fi
if [ -d /arnix ]; then
    error "Arnix is already installed, use 'arnixctl update'"
    exit 1
fi
if [ -d /bedrock ]; then
    error "Bedrock Linux found. Cannot safely continue."
    exit 1
fi
if [ ! -e /sbin/init ]; then
    error "/sbin/init not found, cannot hijack."
    exit 1
fi
if [ ! -d /var/lib/systemd ]; then
    warning "You are about to hijack a distro which does not use systemd. The hijack might or might not brick your distro."
    log 'Press enter to continue'
    read
fi
if [ ! -e $IMAGE_ROOT/etc ] && [ ! -e $IMAGE_ROOT/bin ]; then
    error "Setup files were not found ... (did you not cd into the script's directory?)"
    exit 1
fi

log "Loading shared code"
source $IMAGE_ROOT/bin/shared.sh
alias ln="$IMAGE_ROOT/bin/toybox ln"
alias sha1sum="$IMAGE_ROOT/bin/toybox sha1sum"

log "Sourcing config"
source $IMAGE_ROOT/etc/arnix.conf

echo -e '\033[31m'
cat << END
+                                                                                     +

                                - WARNING -

                    THIS SCRIPT HIJACKS YOUR CURRENT INSTALL!
            EVEN THOUGH THE HIJACK IS REVERSIBLE, DO NOT RELY ON IT.
          MAKE A FULL SYSTEM BACKUP IF YOU TRY THIS ON A REAL MACHINE

+                                                                                     +
END
if ! $unattended_install; then
    echo -e '\033[97m'
    printf 'Type "install Arnix" (all uppercase) to continue: '
    echo -ne '\033(B\033[m'
    read REPLY
    if [ "${REPLY}" != "INSTALL ARNIX" ]; then
        error "Input did not match"
        exit 1
    fi
fi

log "Installing Arnix (1/2)"
mkdir -p /arnix
mkdir -p /arnix/var
mkdir -p /arnix/var/init-hooks

cp -a $IMAGE_ROOT/bin /arnix/bin
cp -a $IMAGE_ROOT/etc /arnix/etc
mv /arnix/etc/arnix.conf /arnix/arnix.conf
#sha1sum arnix.conf >/arnix/.arnix.conf.sha1sum
cp -a $INSTALLER_ROOT/arnix-bootstrap.sha1sum /arnix/var/arnix-bootstrap.sha1sum
cp -a $INSTALLER_ROOT/changelog.txt /arnix/changelog.txt

ln -srfnT /arnix/bin/arnixctl.sh /usr/bin/arnixctl
mv -f /etc/os-release /etc/os-release.arnixsave
ln -srfnT /arnix/etc/os-release /etc/os-release

chmod 755 -R /arnix/bin
chmod 755 /usr/bin/arnixctl

# link package manager hooks here
if [ -n "$(command -v pacman)" ]; then
    mkdir -p /etc/pacman.d/hooks/
    ln -srfnT /arnix/etc/pacman-pre.hook /etc/pacman.d/hooks/0-arnix-create-generation.hook
    ln -srfnT /arnix/etc/pacman-post.hook /etc/pacman.d/hooks/100-arnix-change-symlink.hook
fi

# Workaround for Ubuntu
mkdir -p /var/db

log "Creating generation 1"
mkdir -p /arnix/generations/1
ln -srfnT /arnix/generations/1 /arnix/generations/current
ln -srfnT /arnix/generations/1 /arnix/generations/latest
_ifs=$IFS
IFS=' ' # POSIX standard does not have arrays
for i in ${_dirs}; do
    mkdir -p /arnix/generations/1/$i
    mv /$i/* /arnix/generations/1/$i
done
IFS=$_ifs
cp -a /boot /arnix/generations/1/boot

log "Installing Arnix (2/2)"
ln -srfnT /arnix/bin /usr/bin
# Just to get systemd in initrd working
ln -srfnT /arnix/etc/os-release /etc/os-release
# GRUB themes
mkdir -p /usr/share
ln -srfnT /arnix/generations/current/usr/share/grub /usr/share/grub

log "Activating generation 1"
for i in ${_dirs}; do
    mount --bind /arnix/generations/1/$i /$i
done

log 'Arnix was installed successfully. You may continue using your system'
log "Arnix can now be managed with 'arnixctl'!"