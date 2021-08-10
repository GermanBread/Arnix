#!/bin/bash

cd src/
chmod 755 -R bin
tar c bin etc ../changelog.txt > ../installer/arnix-bootstrap.tar
cd ../installer/
gzip -f arnix-bootstrap.tar
sha1sum arnix-bootstrap.tar.gz > arnix-bootstrap.sha1sum.txt