#!src/bin/busybox sh

source ../src/bin/shared.sh

cd src/
chmod 755 -R bin

create_checksums bin
create_checksums etc

cd ..
fakeroot tar c bin etc ../changelog.txt > ../installer/arnix-bootstrap.tar
cd ../installer/
gzip -f arnix-bootstrap.tar
sha1sum arnix-bootstrap.tar.gz > arnix-bootstrap.sha1sum.txt

cd ..
rm src/**/*.sha1sum.txt