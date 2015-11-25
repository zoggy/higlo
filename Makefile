#################################################################################
#                Higlo                                                          #
#                                                                               #
#    Copyright (C) 2014 Institut National de Recherche en Informatique          #
#    et en Automatique. All rights reserved.                                    #
#                                                                               #
#    This program is free software; you can redistribute it and/or modify       #
#    it under the terms of the GNU Lesser General Public License version        #
#    3 as published by the Free Software Foundation.                            #
#                                                                               #
#    This program is distributed in the hope that it will be useful,            #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#    GNU Library General Public License for more details.                       #
#                                                                               #
#    You should have received a copy of the GNU Lesser General Public           #
#    License along with this program; if not, write to the Free Software        #
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   #
#    02111-1307  USA                                                            #
#                                                                               #
#    Contact: Maxence.Guesdon@inria.fr                                          #
#                                                                               #
#                                                                               #
#################################################################################

# DO NOT FORGET TO BUMP VERSION NUMBER IN META TOO
VERSION=0.5

PACKAGES=ulex,xtmpl
OF_FLAGS=-package $(PACKAGES)
COMPFLAGS=-annot -rectypes -g -safe-string
OCAMLPP=

OCAMLFIND=ocamlfind

LEXERS=\
	higlo_dot.cmx \
	higlo_json.cmx \
	higlo_ocaml.cmx \
	higlo_xml.cmx

LEXERS_BYTE=$(LEXERS:.cmx=.cmo)
LEXERS_CMXS=$(LEXERS:.cmx=.cmxs)

HIGLO=higlo
HIGLO_BYTE=$(HIGLO).byte
MK_HIGLO=mk-higlo

RM=rm -f
CP=cp -f
MKDIR=mkdir -p

all: byte opt
byte: higlo.cmo $(LEXERS_BYTE) $(HIGLO_BYTE)
opt: higlo.cmx higlo.cmxs $(LEXERS) $(LEXERS_CMXS) $(HIGLO) $(MK_HIGLO)

higlo.cmx: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmxs: higlo.cmx
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -shared -o $@ $(COMPFLAGS) higlo.cmx

higlo.cmo: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmi: higlo.mli
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) $<

higlo_printers.cmi: higlo_printers.mli
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) $<
higlo_printers.cmx higlo_printers.cmo: higlo_printers.cmi

$(HIGLO): higlo.cmx $(LEXERS) higlo_printers.cmx higlo_main.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -o $@ -package dynlink -linkpkg $^

$(HIGLO_BYTE): higlo.cmo $(LEXERS_BYTE) higlo_printers.cmo higlo_main.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) $(COMPFLAGS) -o $@ -package dynlink -linkpkg $^

$(MK_HIGLO):
	@echo -n "Creating $@... "
	@$(RM) $@
	@echo "# Multi-shell script.  Works under Bourne Shell, MPW Shell, zsh." > $@
	@echo "if : == x" >> $@
	@echo "then # Bourne Shell or zsh" >> $@
	@echo "  exec $(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -package dynlink,higlo.lexers -linkpkg -linkall $(INCLUDES) higlo_printers.cmx \"\$$@\" higlo_main.cmx" >> $@
	@echo "else #MPW Shell" >> $@
	@echo "  exec $(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -package dynlink,higlo.lexers -linkpkg -linkall $(INCLUDES) higlo_printers.cmx {\"parameters\"} higlo_main.cmx" >> $@
	@echo "End # uppercase E because \"end\" is a keyword in zsh" >> $@
	@echo "fi" >> $@
	@chmod ugo+rx $@
	@chmod a-w $@
	@echo done


%.ml: %.mll
	camlp4o -printer Camlp4OCamlPrinter.cmo \
	`$(OCAMLFIND) query ulex`/pa_ulex.cma -impl $< > $@

%.cmo: %.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) $(COMPFLAGS) -c $<

%.cmx: %.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -c $<

%.cmxs: %.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -shared -o $@ $<

#META:
#	@echo	'version = "$(VERSION)"' > META
#	@echo 'description = "Syntax highlighting"' >> META
#	@echo 'requires = "$(PACKAGES)"' >> META
#	@echo 'archive(toploop) = "higlo.cmo"' >> META
#	@echo 'archive(byte) = "higlo.cmo"' >> META
#	@echo 'archive(native) = "higlo.cmx"' >> META
#	@echo 'archive(native,plugin) = "higlo.cmxs"' >> META
#	@echo 'package "lexers" (' >> META
#	@echo '  version = "$(VERSION)"' >> META
#	@echo '  description = "Higlo lexers"' >> META
#	@echo '  requires = "higlo.ocaml,higlo.xml"' >> META
#	@echo ')' >> META
#	@for i in `echo $(LEXERS) | cut -d'.' -f 1`; do \
#	echo 'package "$$i" ( \
#	  version = "$(VERSION)"' >> META \
#	echo '  description = "Higlo $$i lexer"' >> META \
#	echo '  requires = "higlo"' >> META \
#	echo '  archive(toploop) = "higlo_$$i.cmo"' >> META \
#	echo '  archive(byte) = "higlo_$$i.cmo"' >> META \
#	echo '  archive(native) = "higlo_$$i.cmx"' >> META \
#	echo '  archive(native,plugin) = "higlo_$$i.cmxs"' >> META \
#	echo ')' >> META ; \
#	done

##########
.PHONY: doc META
doc:
	$(MKDIR) doc
	$(OCAMLFIND) ocamldoc $(OF_FLAGS) -rectypes higlo.mli -t Higlo -d doc -html

docstog:
	$(MKDIR) web/refdoc
	$(OCAMLFIND) ocamldoc $(OF_FLAGS) -rectypes higlo.mli \
	-t Higlo -d web/refdoc -i `$(OCAMLFIND) query stog` -g odoc_stog.cmo

webdoc:
	$(MAKE) docstog
	cd web && $(MAKE)

##########
install: install-lib install-bin

install-bin:
	$(CP) $(HIGLO) $(HIGLO_BYTE) $(MK_HIGLO) `dirname \`which ocamlfind\``/

install-lib: higlo.cmo higlo.cmx higlo.cmxs $(HIGLO) $(HIGLO_BYTE)
	ocamlfind install higlo META LICENSE \
		higlo.cmi higlo.mli higlo.cmo higlo.cmx higlo.cmxs higlo.o \
		$(LEXERS) $(LEXERS_CMXS) $(LEXERS_BYTE) $(LEXERS:.cmx=.o) $(LEXERS:.cmx=.cmi) \
		higlo_main.cmi higlo_main.cmo higlo_main.cmx higlo_main.o \
		higlo_printers.cmi higlo_printers.cmo higlo_printers.cmx higlo_printers.o

uninstall: uninstall-bin uninstall-lib

uninstall-bin:
	$(RM) `dirname \`which ocamlfind\``/$(HIGLO)
	$(RM) `dirname \`which ocamlfind\``/$(HIGLO_BYTE)
	$(RM) `dirname \`which ocamlfind\``/$(MK_HIGLO)

uninstall-lib:
	ocamlfind remove higlo

# archive :
###########
archive: META
	git archive --prefix=higlo-$(VERSION)/ HEAD | gzip > ../higlo-gh-pages/higlo-$(VERSION).tar.gz

#####
.PHONY: clean depend

clean:
	$(RM) *.cm* *.o *.annot *.a higlo-test
	$(RM) $(LEXERS) $(LEXERS_CMXS) $(LEXERS_BYTE)
	$(RM) $(MK_HIGLO)

.depend depend:
	$(OCAMLFIND) ocamldep *.ml *.mli > .depend

include .depend

####
# headers :
###########
HEADFILES=Makefile *.ml *.mli *.mll
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)


