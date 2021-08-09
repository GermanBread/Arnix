#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

check_for_action_requirements

echo 'Select branch:'
echo '1 - stable'
echo '2 - unstable'
echo '3 - custom'
while ! [[ $_mode = '[123]' ]] 2>/dev/null; do
    tput sc
    read -n 1 _mode
    tput rc
done
echo

_escape() {
    echo $* | sed 's/\//\\\//gm'
}

case ${_mode} in 
    1)
        sed -Ei "s/_update_source=.+/_update_source=$(_escape 'https://github.com/germanbread/arnix/releases/latest/download/arnix-bootstrap.tar.gz')/" /arnix/etc/arnix.conf
        sed -Ei "s/_branch_preset=\w+/_branch_preset=stable/" /arnix/etc/arnix.conf
        log "Branch changed to 'stable'"
    ;;
    2)
        sed -Ei "s/_update_source=.+/_update_source=$(_escape 'https://raw.githubusercontent.com/GermanBread/Arnix/master/src/arnix-bootstrap.tar.gz')/" /arnix/etc/arnix.conf
        sed -Ei "s/_branch_preset=\w+/_branch_preset=unstable/" /arnix/etc/arnix.conf
        log "Branch changed to 'unstable'"
    ;;
    3)
        question 'Please paste the link to the arnix-bootstrap.tar.gz file here:'
        log 'Testing link'
        wget -qq "${answer}" -O /dev/null
        if [ $? -ne 0 ]; then
            error 'Link errored, no changes were saved'
            exit 1
        fi
        sed -Ei "s/_update_source=.+/_update_source=$(_escape "${answer}")/" /arnix/etc/arnix.conf
        sed -Ei "s/_branch_preset=\w+/_branch_preset=custom/" /arnix/etc/arnix.conf
        log "Branch changed to 'custom'"
    ;;
esac