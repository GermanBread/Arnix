#!/arnix/bin/busybox sh

_echo() {
    [[ "$(cat /proc/cmdline)" != '*quiet*' ]] || [[ "$(cat /proc/cmdline)" = '*arnix.verbose*' ]] && \
        echo $*
}
_emergency() {
    echo $*
    echo "You are in Arnix's emergency mode. Bailing out, good luck."
    echo 'Files for Arnix are stored in /arnix/bin and /arnix/etc'
    echo 'If you exit this shell, the boot process will attempt to continue.'
    echo
    PS1="RESCUE \w # " sh
    echo
    echo 'Logout'
    #exit 1
}
_mount() {
    mount $* || \
        _emergency 'Mount operation failed' || \
            _echo '.. OK'
}

# Explained in shared.sh
#_mkro() {
#    _mount "$*" "$*" -o bind
#    _mount "$*" -o remount,ro,bind
#}

[ $$ -ne 1 ] && \
    echo 'Must be PID 1' && \
        exit 1

[[ "$(cat /proc/cmdline)" = '*arnix.emergency*' ]] && _emergency 'Requested by kernel parameter'

if [ ! -e /arnix/etc/arnix.conf ]; then
    _emergency "Config file /arnix/etc/arnix.conf does not exist"
else
    source /arnix/arnix.conf
    _echo ':: Loaded config'
fi

[ "${_verbose}" = "true" ] || [[ "$(cat /proc/cmdline)" = '*arnix.verbose*' ]] && set -v

echo -ne '\033[35m'
[ "${_show_splash}" = "true" ] && \
cat << splash

          :::     :::::::::  ::::    ::: ::::::::::: :::    ::: 
       :+: :+:   :+:    :+: :+:+:   :+:     :+:     :+:    :+:  
     +:+   +:+  +:+    +:+ :+:+:+  +:+     +:+      +:+  +:+    
   +#++:++#++: +#++:++#:  +#+ +:+ +#+     +#+       +#++:+      
  +#+     +#+ +#+    +#+ +#+  +#+#+#     +#+      +#+  +#+      
 #+#     #+# #+#    #+# #+#   #+#+#     #+#     #+#    #+#      
###     ### ###    ### ###    #### ########### ###    ###

splash
echo -ne '\033(B\033[m'

if [[ "$(cat /proc/cmdline)" = '*arnix.rollback*' ]]; then
    if [ ! -e /arnix/bin/rollback.sh ]; then
        _emergency "Rollback script /arnix/bin/rollback.sh does not exist"
    else
        /arnix/bin/rollback.sh
    fi
fi

[ ! -e /arnix/generations/current ] && \
    _emergency "Symlink to current generation is missing. Create it now or use the rollback script (/arnix/bin/rollback.sh). If you chose the wrong generation."

_echo ":: Starting Arnix ${_arnix_version}"
_echo ":: Mounting / as rw"
_mount -o remount,rw /
[ -e /arnix/var/init-hooks/pre-*.hook ] && \
    _echo ":: Running pre-mount hooks" && \
        for i in /arnix/var/init-hooks/pre-*.hook; do
            sh $i || \
                _emergency "Pre-mount hook $(basename $i) errored"
        done
_echo ":: Booting generation $(readlink /arnix/generations/current)"
_errored=0

_ifs=$IFS
IFS=' '
for i in ${_dirs}; do
    _echo ":: Mounting $i"
    if [ -d /arnix/generations/current/$i ]; then
        mountpoint /$i &>/dev/null || \
            _mount -o bind,rw /arnix/generations/current/$i /$i
    else
        _echo '.. WARNING: Directory not found in /arnix/generations/current'
        _errored=1
    fi
done
IFS=$_ifs
unset _ifs _dirs

[ -e /arnix/var/init-hooks/post-*.hook ] && \
    _echo ":: Running post-mount hooks" && \
        for i in /arnix/var/init-hooks/post-*.hook; do
            sh $i || \
                _emergency "Post-mount hook $(basename $i) errored"
        done

[ ${_errored} -ne 0 ] && \
    _echo ':: Errors occured, freezing execution for 15 seconds' && \
        sleep 15s

# Don't interrupt the hooks, do the read-only part as last
#_echo ":: Mounting /arnix/etc as ro"
#_mkro /arnix/etc
#_echo ":: Mounting /arnix/bin as ro"
#_mkro /arnix/bin
#_echo ":: Mounting inactive generations as ro"
#for i in /arnix/generations/*; do
#    readlink $i &>/dev/null || \
#        _mkro $i
#done
#umount -l /arnix/generations/current

if [[ "$(readlink /sbin)" = '/arnix*' ]]; then
    _echo '!! /sbin points to a directory in /arnix'
    _echo ':: Attempting to fix this automatically'
    cd /
    ln -sfT usr/bin sbin || \
        _emergency 'Recreating the symlink failed'
    cd - &>/dev/null
    sleep 5s
fi
_echo ':: Handing off control'
if [ ! -e /sbin/init ]; then
    _emergency '/sbin/init not found'
else
    _echo '.. OK'
fi
exec /sbin/init