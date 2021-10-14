#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

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
    log "Copying script to predictable location"
    cp $0 /tmp/arnix-update.script.sh
    exec /tmp/arnix-update.script.sh
fi

log "Downloading update for branch '${_branch_preset}', URL '${_update_source_tarball}'"
rm -rf /tmp/arnix-update
mkdir -m 700 -p /tmp/arnix-update
cd /tmp/arnix-update
curl -sL "${_update_source_tarball}" >arnix-bootstrap.tar.gz
if [ $? -ne 0 ]; then
    error 'Unable to download update. There might be something relevant in the news though https://germanbread.github.io/Arnix/news.html'
    exit 1
fi
if [ -n "${_update_source_checksum}" ]; then
    curl -sL "${_update_source_checksum}" >arnix-bootstrap.sha1sum.txt
    if [ $? -ne 0 ]; then
        warning 'Checksum URL was specified in arnix.conf but it could not be downloaded!'
    fi
fi

if [ -e arnix-bootstrap.sha1sum.txt ]; then
    sha1sum -c arnix-bootstrap.sha1sum.txt --status
    if [ $? -ne 0 ]; then
        warning 'Checksums did not match. Something nasty might be going on'
        log 'Press enter to continue'
        read
    fi
fi

if [ -e /arnix/arnix-bootstrap.sha1sum.txt ]; then
    sha1sum -c /arnix/arnix-bootstrap.sha1sum.txt --status
    if [ $? -eq 0 ]; then
        log 'Arnix is already up to date, no updates required'
        [ "$1" = 'force' ] && \
            log 'Update forced by user' || \
                exit 0
    fi
fi

sha1sum arnix-bootstrap.tar.gz >/tmp/arnix-update/arnix-bootstrap.sha1sum.txt
gunzip arnix-bootstrap.tar.gz
tar xf arnix-bootstrap.tar

less -~N changelog.txt
question 'Continue [y/N]?'
! [[ "${answer}" =~ [yY].* ]] && exit 1

rm -rf /arnix/merge
mkdir -p /arnix/merge
mv /tmp/arnix-update/arnix-bootstrap.sha1sum.txt /arnix/arnix-bootstrap.sha1sum.txt
cp -a bin /arnix/merge/bin
cp -a etc /arnix/merge/etc
cp -a changelog.txt /arnix/changelog.txt

cd /arnix/etc
umount -l /arnix/etc
for i in *; do
    [ ! -e /arnix/merge/etc/$i ] && rm -rf /arnix/etc/$i && continue
    
    # Check if the original checksum still matches
    ([ -e .$i.sha1sum.txt ] && \
        sha1sum -c .$i.sha1sum.txt --status) || \
            [[ "$i" = '.*.sha1sum.txt' ]] &>/dev/null
    
    # If it does we can overwrite it
    if [ $? -eq 0 ]; then
        cp -rf /arnix/merge/etc/$i $i
    else
        cp -rf /arnix/merge/etc/$i $i.arnixnew
    fi
    [ -e /arnix/merge/etc/.$i.sha1sum.txt ] && \
        cp -rf /arnix/merge/etc/.$i.sha1sum.txt .
done
cd /arnix/merge/etc
for i in *; do
    [ ! -e /arnix/etc/$i ] && \
        cp -rf /arnix/merge/etc/$i /arnix/etc/$i
done
makero /arnix/etc

cd /arnix/bin
umount -l /arnix/bin
mv /arnix/bin /arnix/bin~ # Too afraid to use shell globs here
mv /arnix/merge/bin /arnix/bin
rm -rf /arnix/bin~
makero /arnix/bin

if [ -e /tmp/arnix-update/post-update.sh ]; then
    log 'Running post-update script'
    sh /tmp/arnix-update/post-update.sh
fi

rm -r /tmp/arnix-update
rm -r /arnix/merge

warning 'Manual intervention might be required - files might need to be merged.'
warning '/arnix/etc/FILE.arnixnew -> /arnix/etc/FILE'
exit