all: builddir bootstrap

builddir:
	rm -r build
	mkdir -p build

installer: bootstrap
	cd src/installer && $(MAKE)

bootstrap:
	cd src/image && $(MAKE)