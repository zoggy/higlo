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
VERSION=0.1

PACKAGES=ulex
OF_FLAGS=-package $(PACKAGES)
COMPFLAGS=-annot -g
OCAMLPP=

OCAMLFIND=ocamlfind

LEXERS=higlo_ocaml.cmx
LEXERS_BYTE=$(HIGLO_LEXERS:.cmx=.cmo)
LEXERS_CMXS=$(HIGLO_LEXERS:.cmx=.cmxs)

RM=rm -f
CP=cp -f
MKDIR=mkdir -p

all: byte opt
byte: higlo.cmo $(LEXERS_BYTE)
opt: higlo.cmx higlo.cmxs $(LEXERS) $(LEXERS_CMXS)

higlo.cmx: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmxs: higlo.cmx
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -shared -o $@ $(COMPFLAGS) higlo.cmx

higlo.cmo: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmi: higlo.mli
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) $<

$(MAIN): higlo.cmx higlo_main.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -o $@ -linkpkg $^

$(MAIN_BYTE): higlo.cmo higlo_main.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) $(COMPFLAGS) -o $@ -linkpkg $^

higlo-test: higlo.cmx higlo_ocaml.cmx higlo_test.cmx
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -o $@ -linkpkg -linkall $^

%.ml: %.mll
	camlp4o -printer Camlp4OCamlPrinter.cmo \
	`$(OCAMLFIND) query ulex`/pa_ulex.cma -impl $< > $@

%.cmo: %.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) $(COMPFLAGS) -c $<

%.cmx: %.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -c $<

%.cmxs: %.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -shared $<

##########
.PHONY: doc
doc:
	$(MKDIR) doc
	$(OCAMLFIND) ocamldoc $(OF_FLAGS) -rectypes higlo.mli -t Higlo -d doc -html

docstog:
	$(MKDIR) web/refdoc
	$(OCAMLFIND) ocamldoc $(OF_FLAGS) -rectypes higlo.mli \
	-t Higlo -d web/refdoc -g odoc_stog.cmo

webdoc:
	$(MAKE) docstog
	cd web && $(MAKE)

##########
install: higlo.cmo higlo.cmx higlo.cmxs
	ocamlfind install higlo META LICENSE \
		higlo.cmi higlo.mli higlo.cmo higlo.cmx higlo.cmxs higlo.o

uninstall:
	ocamlfind remove higlo

# archive :
###########
archive:
	git archive --prefix=higlo-$(VERSION)/ HEAD | gzip > ../higlo-gh-pages/higlo-$(VERSION).tar.gz

#####
.PHONY: clean depend

clean:
	$(RM) *.cm* *.o *.annot *.a test-higlo
	$(RM) $(LEXERS) $(LEXERS_CMXS) $(LEXERS_BYTE)

.depend depend:
	$(OCAMLFIND) ocamldep *.ml *.mli > .depend

include .depend

####
# headers :
###########
HEADFILES=Makefile *.ml *.mli
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)


