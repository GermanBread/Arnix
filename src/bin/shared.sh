if [ -d /arnix ]; then
    alias ln='/arnix/bin/toybox ln'
    alias sha1sum='/arnix/bin/toybox sha1sum'
fi

log() {
    printf "\033[35m[-] INFO:\033(B\033[m $*\n"
}
warning() {
    printf "\033[33m[=] WARNING:\033(B\033[m $*\n"
}
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
# Use $answer to retrieve the response
question() {
    printf "\033[36m[?] QUESTION:\033(B\033[m $* "
    read answer
}
# Checks if the requirements for the scripts are statisfied, if else exists
check_for_action_requirements() {
    if [ $(id -u) -ne 0 ]; then
        error "This script needs to run as root"
        exit 1
    fi
    if [ ! -d /arnix ]; then
        error "Arnix is not installed"
        exit 1
    fi
}
# Hacky workaround explained here https://unix.stackexchange.com/a/128388
# TL;DR busybox's libmount is really old
makero() {
    mount "$*" "$*" -o bind
    mount "$*" -o remount,ro,bind
}
# recursively creates checksums
create_checksums() {
    _prepwd=$PWD
    cd $1
    rm -f *.sha1sum.txt
    for i in $(ls -1); do
        [ ! -e $i ] && continue
        [ -d $i ] && create_checksums "$i" && continue
        sha1sum $i > .$i.sha1sum.txt
    done
    cd ${_prepwd}
}