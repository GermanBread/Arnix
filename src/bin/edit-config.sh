#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/etc/arnix.conf

[ "${_verbose}" = "true" ] && set -v

[ -z "$EDITOR" ] && EDITOR=vi

umount -l /arnix/etc
$EDITOR /arnix/etc/arnix.conf
makero /arnix/etc