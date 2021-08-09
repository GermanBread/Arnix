#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

echo 'Select branch:'
echo '1 - stable'
echo '2 - unstable'
echo '3 - custom'
while ! [[ $_mode = [123] ]] 2>/dev/null; do
    printf '\0337'
    read -n 1 _mode
    printf '\0338'
done
echo

case ${_mode} in 
    1)
        sed -Ei "s,_update_source=.+,_update_source=https://github.com/germanbread/arnix/releases/latest/download/arnix-bootstrap.tar.gz," /arnix/etc/arnix.conf
        sed -Ei "s,_branch_preset=\w+,_branch_preset=stable," /arnix/etc/arnix.conf
        log "Branch changed to 'stable'"
    ;;
    2)
        sed -Ei "s,_update_source=.+,_update_source=https://raw.githubusercontent.com/GermanBread/Arnix/master/src/arnix-bootstrap.tar.gz," /arnix/etc/arnix.conf
        sed -Ei "s,_branch_preset=\w+,_branch_preset=unstable," /arnix/etc/arnix.conf
        log "Branch changed to 'unstable'"
    ;;
    3)
        question 'Please paste the link to the arnix-bootstrap.tar.gz file here:'
        log 'Testing link'
        curl -s "${answer}" >/dev/null
        if [ $? -ne 0 ]; then
            error 'Link errored, no changes were saved'
            exit 1
        fi
        sed -Ei "s,_update_source=.+,_update_source=${answer}," /arnix/etc/arnix.conf
        sed -Ei "s,_branch_preset=\w+,_branch_preset=custom," /arnix/etc/arnix.conf
        log "Branch changed to 'custom'"
    ;;
esac