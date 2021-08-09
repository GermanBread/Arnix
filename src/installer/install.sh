#!/bin/sh
error() {
    printf "\033[31m[!] ERROR:\033(B\033[m $*\n"
}
if [ -z "$(command -v curl)" ]; then
    error "This script requires curl"
    exit 1
fi

tarball=$(curl -s https://api.github.com/repos/GermanBread/Arnix/releases/latest | grep tarball | egrep -o 'https://.+\"' | head -c -2)
temp=$(mktemp -d)
cd $temp
curl -SL ${tarball} > latest.tar.gz
[ $? -ne 0 ] && exit
gunzip latest.tar.gz
tar xf latest.tar
rm latest.tar
cd */src
./hijack.sh