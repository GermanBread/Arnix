#!src/bin/busybox sh

alias sha1sum="$(pwd)/src/bin/toybox sha1sum"

cd src/
chmod 755 -R bin

sha1sum arnix.conf > .arnix.conf.sha1sum
fakeroot tar c bin etc arnix.conf .arnix.conf.sha1sum > ../installer/arnix-bootstrap.tar
cd ../installer
chmod +x post-update.sh
fakeroot tar rf arnix-bootstrap.tar changelog.txt post-update.sh
gzip -f arnix-bootstrap.tar
sha1sum arnix-bootstrap.tar.gz > arnix-bootstrap.sha1sum

cd ..
rm -f src/.arnix.conf.sha1sum