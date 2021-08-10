files_scss := $(wildcard *.scss)
output_scss := $(foreach file,$(files_scss),$(shell basename -s .scss $(file)))
files_ts := $(wildcard *.ts)
output_ts := $(foreach file,$(files_ts),$(shell basename -s .ts $(file)))

all:
	mkdir -p compiled
	@echo Compiling scss to css
	@echo =====================
	@make $(output_scss)
	@echo =====================
	@echo Compilation completed
	@echo Compiling ts to js
	@echo =====================
	@make $(output_ts)
	@echo =====================
	@echo Compilation completed

deploy: all
	rm -rf ../docs/*
	mv compiled ../docs/compiled
	cp -r images ../docs/images
	cp *.html ../docs/

$(output_scss):
	@echo Processing $@
	sassc -t compressed $@.scss > compiled/$@.css

$(output_ts):
	@echo Processing $@
	tsc --outFile compiled/$@.js $@.ts