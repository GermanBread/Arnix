#!src/bin/busybox sh

create_checksums() {
    _prepwd=$PWD
    cd $1
    rm -f *.sha1sum.txt
    for i in $(ls -1); do
        [ -d $i ] && create_checksums "$i" && continue
        sha1sum $i > $i.sha1sum.txt
    done
    cd ${_prepwd}
}

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