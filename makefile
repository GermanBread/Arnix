all: builddir bootstrap installer

builddir:
	rm -rf build
	mkdir -p build

installer: bootstrap
	cd src/installer && $(MAKE)

bootstrap:
	cd src/image && $(MAKE)

mkinst: all
	rm -rf installer
	mv build installer