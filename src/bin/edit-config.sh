#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

[ -z "$EDITOR" ] && EDITOR=vi

#umount -l /arnix/etc
$EDITOR /arnix/arnix.conf
#makero /arnix/etc