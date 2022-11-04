#!/bin/sh
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi
if [ -z $TARBALL ]; then
    TARBALL='https://github.com/GermanBread/Arnix/archive/refs/heads/stable.tar.gz';
fi

temp=$(mktemp -d)
cd $temp
curl -SL $TARBALL >latest.tar.gz
[ $? -ne 0 ] && exit 1
tar xf latest.tar.gz
rm latest.tar.gz
cd */src
./hijack.sh