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
COMPFLAGS=-annot -rectypes -g
OCAMLPP=

OCAMLFIND=ocamlfind

RM=rm -f
CP=cp -f
MKDIR=mkdir -p

all: byte opt
byte: higlo.cmo
opt: higlo.cmx higlo.cmxs

higlo.cmx: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmxs: higlo.cmx
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) -shared -o $@ $(COMPFLAGS) higlo.cmx

higlo.cmo: higlo.cmi higlo.ml
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) higlo.ml

higlo.cmi: higlo.mli
	$(OCAMLFIND) ocamlc $(OF_FLAGS) -c $(COMPFLAGS) $<

test-higlo: higlo.cmx test_higlo.ml
	$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(COMPFLAGS) -o $@ -linkpkg $^

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
clean:
	$(RM) *.cm* *.o *.annot *.a test-higlo

# headers :
###########
HEADFILES=Makefile *.ml *.mli
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)


