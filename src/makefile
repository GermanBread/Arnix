all:
	rm -f arnix-bootstrap.tar.gz
	chmod 755 -R bin etc
	fakeroot tar c bin etc ../changelog.txt > arnix-bootstrap.tar
	gzip arnix-bootstrap.tar