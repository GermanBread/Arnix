#!/bin/sh
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

tarball="https://raw.githubusercontent.com/GermanBread/Arnix/stable/installer/arnix-bootstrap.tar.gz"
temp=$(mktemp -d)
cd $temp
curl -SL ${tarball} > latest.tar.gz
[ $? -ne 0 ] && exit
gunzip latest.tar.gz
tar xf latest.tar
rm latest.tar
cd */src
./hijack.sh