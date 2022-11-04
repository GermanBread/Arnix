BUILD := ../../build

all:
	chmod 755 -R bin
	fakeroot tar c bin etc update >$(BUILD)/arnix-bootstrap.tar
	gzip -f $(BUILD)/arnix-bootstrap.tar
	cd $(BUILD) && sha1sum arnix-bootstrap.tar.gz >arnix-bootstrap.sha1sum