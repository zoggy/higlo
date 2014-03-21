STOG=stog
DEST_DIR=`pwd`/../../higlo-gh-pages
MORE_OPTIONS=
STOG_OPTIONS=-d $(DEST_DIR) $(MORE_OPTIONS)
LESSC=lessc
CP=cp -f

build:
	$(MAKE) site

style.css: less/*.less
	$(LESSC) less/style.less > $@

site: style.css usage.txt myprinter
	$(STOG) $(STOG_OPTIONS) .
	$(CP) style.css $(DEST_DIR)/style.css

test:
	$(MAKE) MORE_OPTIONS="--local" site

usage.txt: ../higlo
	$< --help | tail -n +2 > $@

myprinter: myprinter.ml
	mk-higlo $< -o $@

clean:
	rm -fr .stog/cache usage.txt
	rm -f myprinter myprinter.cm* myprinter.o myprinter.annot



	