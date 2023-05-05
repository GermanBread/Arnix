#!/arnix/bin/busybox sh

source /arnix/bin/shared.sh
source /arnix/arnix.conf

[ "${_verbose}" = "true" ] && set -v

check_for_action_requirements

copy=true
pretty=true
symlink=true

for i in $@; do
    case $i in
        nocopy)
            copy=false
        ;;
        nosymlink)
            symlink=false
        ;;
        --hook)
            pretty=false
        ;;
    esac
    shift
done

_current_generation=$(readlink /arnix/generations/current)
_next_generation=$((${_current_generation} + 1))

if $copy; then
cat << EOF >/arnix/var/init-hooks/pre-undo_new_generation.hook
echo "update got interrupted - undoing changes"
rm -rf /arnix/generations/${_next_generation}
rm -f /arnix/var/init-hooks/pre-undo_new_generation.hook
EOF

    log "Creating new generation ${_next_generation}"
    log "Cloning generation ${_current_generation}"
    
    if $pretty; then
        if [ -e /arnix/generations/${_next_generation} ]; then
            rm -rfv /arnix/generations/${_next_generation} | progress_unknown "Making some free space"
        fi
        
        _tmpfile=$(mktemp)
        find /arnix/generations/${_current_generation} -type f 2>/dev/null | while read r; do
            echo -n x >>$_tmpfile
            echo x
        done | progress_unknown_lc "Counting files needed for transaction"
        _file_count=$(wc -m $_tmpfile | awk '{print$1}')
        rm $_tmpfile

        cp -val /arnix/generations/${_current_generation} /arnix/generations/${_next_generation} | progress_lc $_file_count "Creating generation"
    else
        rm -rf /arnix/generations/${_next_generation}
        cp -al /arnix/generations/${_current_generation} /arnix/generations/${_next_generation}
    fi
fi

if $symlink; then
    cp -a /boot /arnix/generations/${_current_generation}/boot
    
    ln -srfnT /arnix/generations/${_next_generation} /arnix/generations/current
    ln -srfnT /arnix/generations/$(ls /arnix/generations | sort -g | tail -n 1) /arnix/generations/latest

    rm /arnix/var/init-hooks/pre-undo_new_generation.hook
fi
if $copy; then
    log "Activating generation ${_next_generation}"
    for i in ${_dirs}; do
        /arnix/bin/busybox umount -l /$i
        # Should run once but whatever
        ln -srfnT /arnix/generations/${_next_generation}/usr/share/grub /usr/share/grub
        /arnix/bin/busybox mount --bind /arnix/generations/${_next_generation}/$i /$i
    done
    # remove db lock
    rm -f /arnix/generations/${_current_generation}/var/lib/pacman/db.lck 2>/dev/null
fi