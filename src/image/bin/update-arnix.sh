#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

if [ -d /arnix/merge ]; then
    warning 'There are unmerged files in /arnix/merge'
    warning 'Did the update get interrupted?'
fi

if [[ "$0" = '/arnix*' ]]; then
    log "Copying script to safe location"
    cp $0 /tmp/arnix-update.script.sh
    exec /tmp/arnix-update.script.sh $@
fi

log "Preparing"
mkdir -p /arnix/var
rm -rf /tmp/arnix-update
mkdir -m 700 -p /tmp/arnix-update
cd /tmp/arnix-update
if [ -n "${_update_source_checksum}" ]; then
    curl -sL "${_update_source_checksum}" >arnix-bootstrap.sha1sum
    if [ $? -ne 0 ]; then
        warning 'Checksum URL was specified in arnix.conf but it could not be downloaded!'
    fi
fi

if [ -e /arnix/var/arnix-bootstrap.sha1sum ]; then
    if cmp -s /arnix/var/arnix-bootstrap.sha1sum arnix-bootstrap.sha1sum; then
        log 'Arnix is already up to date, no updates needed'
        [ "$1" = 'force' ] && \
            warning 'Update forced by user' || \
                exit 0
    fi
fi

log "Downloading update for branch '${_branch_preset}', URL '${_update_source_tarball}'"
curl -sL "${_update_source_tarball}" >arnix-bootstrap.tar.gz
if [ $? -ne 0 ]; then
    error 'Unable to download update. There might be something relevant in the news though https://germanbread.github.io/Arnix/news.html'
    exit 1
fi

if [ -e arnix-bootstrap.sha1sum ]; then
    sha1sum -cs arnix-bootstrap.sha1sum
    if [ $? -ne 0 ]; then
        warning 'Checksums did not match. Something nasty might be going on'
        log 'Press enter to continue'
        read
    fi
fi

sha1sum arnix-bootstrap.tar.gz >/tmp/arnix-update/arnix-bootstrap.sha1sum
gunzip arnix-bootstrap.tar.gz
tar xf arnix-bootstrap.tar

less -~N update/changelog.txt
question 'Continue [y/N]?'
! [[ "${answer}" =~ [yY].* ]] && exit 1

rm -rf /arnix/merge # sanity check
mkdir -p /arnix/merge

mv /tmp/arnix-update/arnix-bootstrap.sha1sum /arnix/var/arnix-bootstrap.sha1sum

cp -a bin /arnix/merge/bin
cp -a etc /arnix/merge/etc
cp -a update/changelog.txt /arnix/var/changelog.txt

# Atomic upgrade procedure
mv /arnix/etc /arnix/etc~
mv /arnix/merge/etc /arnix/etc

mv /arnix/bin /arnix/bin~
mv /arnix/merge/bin /arnix/bin

rm -rf /arnix/etc~ /arnix/bin~

if [ -e /tmp/arnix-update/update/post-update.sh ]; then
    log 'Running post-update script'
    sh /tmp/arnix-update/update/post-update.sh
fi

rm -r /tmp/arnix-update
rm -r /arnix/merge

log 'Update complete. Merge /arnix/arnix.conf.new at your convenience.'
exit