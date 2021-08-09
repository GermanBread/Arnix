#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

if [ -d /arnix/merge ]; then
    error 'There are unmerged files in /arnix/merge'
    error 'Delete /arnix/merge when all files are merged / discarded'
    exit 1
fi

log "Downloading update for branch '${_branch_preset}', URL '${_update_source}'"
mkdir -p /tmp/arnix-update
cd /tmp/arnix-update
curl -s "${_update_source}" >bootstrap.tar.gz
if [ $? -ne 0 ]; then
    error 'Unable to download update'
    exit 1
fi
gunzip bootstrap.tar.gz
tar xf bootstrap.tar

less changelog.txt
rm -rf /arnix/merge
mkdir -p /arnix/merge
cp -a bin /arnix/merge/bin
cp -a etc /arnix/merge/etc
cp -a changelog.txt /arnix/changelog.txt
rm -r /tmp/arnix-update

warning "Manual intervention is required - files need to be merged. Because guess what, merging updates is harder than it sounds."
warning '/arnix/merge/ -> /arnix'
warning 'Delete /arnix/merge when you are done'
exit