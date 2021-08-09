#!/bin/bash

cd src/
tar c bin etc ../changelog.txt > ../installer/arnix-bootstrap.tar
cd ../installer/
gzip -f arnix-bootstrap.tar