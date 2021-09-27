#!src/bin/busybox sh

source src/bin/shared.sh
alias sha1sum="$(pwd)/src/bin/toybox sha1sum"

cd src/
chmod 755 -R bin

# /arnix/bin gets overwritten anyways
#create_checksums bin
# Reminder:
#    These checksums were not meant to check file integrity,
#    the only reason why they exist is to tell if a file has been modified
create_checksums etc
cd ..

fakeroot tar c bin etc > ../installer/arnix-bootstrap.tar
cd ../installer
chmod +x post-update.sh
fakeroot tar rf arnix-bootstrap.tar changelog.txt post-update.sh
gzip -f arnix-bootstrap.tar
sha1sum arnix-bootstrap.tar.gz > arnix-bootstrap.sha1sum.txt

cd ..
rm src/**/.*.sha1sum.txt