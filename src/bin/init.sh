#!/arnix/bin/busybox sh

_echo() {
    [[ "$(cat /proc/cmdline)" != '*quiet*' ]] || [[ "$(cat /proc/cmdline)" = '*arnix.verbose*' ]] && \
        echo $*
}
_emergency() {
    echo $*
    echo 'You are in emergency mode. Bailing out, good luck.'
    echo 'Files for Arnix are stored in /arnix/bin and /arnix/etc'
    echo
    PS1="RESCUE \w # " sh
    echo
    echo 'Logout'
    #exit 1
}

[ $$ -ne 1 ] && \
    echo 'Must be PID 1' && \
        exit 1

if [ ! -e /arnix/etc/arnix.conf ]; then
    _emergency "Config file /arnix/etc/arnix.conf does not exist"
else
    source /arnix/etc/arnix.conf
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

if [[ "$(cat /proc/cmdline)" = '*rollback*' ]]; then
    if [ ! -e /arnix/bin/rollback.sh ]; then
        _emergency "Rollback script /arnix/bin/rollback.sh does not exist"
    else
        /arnix/bin/rollback.sh
    fi
fi

_echo ":: Starting Arnix version ${_arnix_version}"
_echo ":: Running pre-mount hooks"
[ -n "$(ls /arnix/etc/init-hooks)" ] && \
    for i in /arnix/etc/init-hooks/pre-*.hook; do
        chmod +x $i
        sh $i
        [ $? -ne 0 ] && \
            _emergency "Pre-mount hook $(basename $i) errored"
    done
_echo ":: Booting generation $(readlink /arnix/generations/current)"
_errored=0

_ifs=$IFS
IFS=' '
_echo ":: Mounting / as rw"
mount -o remount,rw /
[ $? -ne 0 ] && \
    _emergency 'Mount operation failed' || \
        _echo '.. OK'
for i in ${_dirs}; do
    _echo ":: Mounting $i"
    if [ -d /arnix/generations/current/$i ]; then
        mountpoint /$i >/dev/null
        [ $? -ne 0 ] && \
            mount -o bind,rw /arnix/generations/current/$i /$i
        [ $? -ne 0 ] && \
            _emergency 'Mount operation failed' || \
                _echo '.. OK'
    else
        _echo '.. WARNING: Directory not found in /arnix/generations/current'
        _errored=1
    fi
done
IFS=$_ifs
unset _ifs _dirs

_echo ":: Running post-mount hooks"
[ -n "$(ls /arnix/etc/init-hooks)" ] && \
    for i in /arnix/etc/init-hooks/post-*.hook; do
        chmod +x $i
        sh $i
        [ $? -ne 0 ] && \
            _emergency "Post-mount hook $(basename $i) errored"
    done

[ ${_errored} -ne 0 ] && \
    _echo ':: Errors occured, freezing execution for 15 seconds' && \
        sleep 15s

_echo ':: Handing off control'
if [ ! -e /sbin/init ]; then
    _emergency '/sbin/init not found'
else
    _echo '.. OK'
fi
exec /sbin/init