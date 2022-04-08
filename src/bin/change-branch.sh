#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

echo 'Select branch:'
echo '1 - stable'
echo '2 - dev'
echo '3 - custom'
while ! [[ $_mode = [123] ]] 2>/dev/null; do
    printf '\0337'
    read -n 1 _mode
    printf '\0338'
done
echo

case ${_mode} in 
    1)
        sed -Ei "s,_update_source_tarball=.*,_update_source_tarball=https://raw.githubusercontent.com/GermanBread/Arnix/stable/installer/arnix-bootstrap.tar.gz," /arnix/arnix.conf
        sed -Ei "s,_update_source_checksum=.*,_update_source_checksum=https://raw.githubusercontent.com/GermanBread/Arnix/stable/installer/arnix-bootstrap.sha1sum," /arnix/arnix.conf
        sed -Ei "s,_branch_preset=.*,_branch_preset=unstable," /arnix/arnix.conf
        log "Branch changed to 'stable'"
    ;;
    2)
        sed -Ei "s,_update_source_tarball=.*,_update_source_tarball=https://raw.githubusercontent.com/GermanBread/Arnix/dev/installer/arnix-bootstrap.tar.gz," /arnix/arnix.conf
        sed -Ei "s,_update_source_checksum=.*,_update_source_checksum=https://raw.githubusercontent.com/GermanBread/Arnix/dev/installer/arnix-bootstrap.sha1sum," /arnix/arnix.conf
        sed -Ei "s,_branch_preset=.*,_branch_preset=unstable," /arnix/arnix.conf
        log "Branch changed to 'dev'"
    ;;
    3)
        question 'Please paste the link to the arnix-bootstrap.tar.gz file here:'
        tarball="${answer}"
        question 'Please paste the link to the arnix-bootstrap.sha1sum.txt file here (press enter to skip):'
        checksum="${answer}"
        log 'Testing tarball link'
        curl -s "${tarball}" >/dev/null
        if [ $? -ne 0 ]; then
            error 'Link errored, no changes were saved'
            exit 1
        fi
        if [ -n "${checksum}" ]; then
            log 'Testing checksum link'
            curl -s "${checksum}" >/dev/null
            if [ $? -ne 0 ]; then
                error 'Link errored, no changes were saved'
                exit 1
            fi
        fi
        sed -Ei "s,_update_source_tarball=.*,_update_source_tarball=${tarball}," /arnix/arnix.conf
        sed -Ei "s,_update_source_checksum=.*,_update_source_checksum=${checksum}," /arnix/arnix.conf
        sed -Ei "s,_branch_preset=.*,_branch_preset=custom," /arnix/arnix.conf
        log "Branch changed to 'custom'"
    ;;
esac