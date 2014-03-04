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

site: style.css
	$(STOG) $(STOG_OPTIONS) .
	$(CP) style.css $(DEST_DIR)/style.css

test:
	$(MAKE) MORE_OPTIONS="--local" site

clean:
	rm -fr .stog/cache



	