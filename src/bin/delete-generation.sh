#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

ls /arnix/generations | sort | head -n -2
question 'Which generation should be deleted?'
_generation="$answer"
[ -z "$answer" ] && \
    exit 1
if [ ! -d /arnix/generations/${_generation} ]; then
    error "Generation ${_generation} does not exist"
    exit 1
fi

if [[ ${_generation} != [0123456789]* ]]; then
    error 'Input must be an integer'
    exit 1
fi

if [ $(readlink /arnix/generations/current) = ${_generation} ]; then
    error 'You cannot delete the active generation'
    exit 1
fi

ln -srfT /arnix/generations/$(ls /arnix/generations | sort -g | tail -n 1) /arnix/generations/latest

rm -r /arnix/generations/${_generation}

log "Generation ${_generation} deleted"