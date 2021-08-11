#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

if [ -d /arnix/merge ]; then
    error 'There are unmerged files in /arnix/merge'
    error "Delete /arnix/merge when you're done"
    exit 1
fi

log "Downloading update for branch '${_branch_preset}', URL '${_update_source}'"
rm -rf /tmp/arnix-update
mkdir -m 700 -p /tmp/arnix-update
cd /tmp/arnix-update
curl -SsL "${_update_source_tarball}" >arnix-bootstrap.tar.gz
if [ $? -ne 0 ]; then
    error 'Unable to download update. There might be something relevant in the news though https://germanbread.github.io/Arnix/news.html'
    exit 1
fi
if [ -n "${_update_source_checksum}" ]; then
    curl -SsL "${_update_source_checksum}" >arnix-bootstrap.sha1sum.txt
    if [ $? -ne 0 ]; then
        warning 'Checksum URL was specified in arnix.conf but it could not be downloaded!'
    fi
fi

if [ -e arnix-bootstrap.sha1sum.txt ]; then
    sha1sum -c arnix-bootstrap.sha1sum.txt
    if [ $? -ne 0 ]; then
        warning 'Checksums did not match. Something nasty might be going on'
        read
    fi
fi

if [ -e /arnix/arnix-bootstrap.sha1sum.txt ]; then
    sha1sum -c /arnix/arnix-bootstrap.sha1sum.txt
    if [ $? -eq 0 ]; then
        log 'Arnix is already up to date, no updates required'
        exit 0
    fi
fi

gunzip arnix-bootstrap.tar.gz
tar xf arnix-bootstrap.tar

less changelog.txt
question 'Continue [y/N]?'
! [[ "${answer}" =~ [yY].* ]] && exit 1

rm -rf /arnix/merge
mkdir -p /arnix/merge
cp -a bin /arnix/merge/bin
cp -a etc /arnix/merge/etc
cp -a changelog.txt /arnix/changelog.txt
cp -a arnix-bootstrap.sha1sum.txt /arnix/arnix-bootstrap.sha1sum.txt

cd /arnix/etc
for i in *; do
    # Check if the original checksum still matches
    [ -e $i.sha1sum.txt ] && \
        sha1sum -c $i.sha1sum.txt
    
    # If it does we can overwrite it
    if [ $? -eq 0 ]; then
        mv /arnix/merge/etc/$i $i
        mv -f /arnix/merge/etc/$i.sha1sum.txt $i.sha1sum.txt
    else
        mv /arnix/merge/etc/$i $i.arnixnew
        mv -f /arnix/merge/etc/$i.sha1sum.txt $i.sha1sum.txt.arnixnew
    fi
done

cd /arnix/bin
for i in *; do
    [ ! -e /arnix/merge/bin/$i ] && rm -f /arnix/bin/$i
    
    mv -f /arnix/merge/bin/$i $i
    mv -f /arnix/merge/bin/$i.sha1sum.txt $i.sha1sum.txt
done

rm -r /tmp/arnix-update
rm -r /arnix/merge

warning 'Manual intervention is required - files need to be merged. Because guess what, merging updates is harder than it sounds.'
warning '/arnix/etc/FILE.arnixnew -> /arnix/etc/FILE'
exit