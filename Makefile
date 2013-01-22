
MLS=\
	netaddr.ml \
	unixaddr.ml

CMXS=$(MLS:.ml=.cmx)
CMOS=$(MLS:.ml=.cmo)
MLIS=$(MLS:.ml=.mli)
CMIS=$(MLS:.ml=.cmi)

BINNAME=run


OCAMLOPTOPTIONS=
OCAMLCOPTIONS=-g
OCAMLOPT=ocamlopt $(OCAMLOPTOPTIONS)
OCAMLC=ocamlc $(OCAMLCOPTIONS)
OCAMLLEX=ocamllex
MENHIROPTIONS=--explain
MENHIR=menhir $(MENHIROPTIONS)
OCAMLDEP=ocamldep

all: $(BINNAME).byte
native: $(BINNAME).native
byte: $(BINNAME).byte

$(BINNAME).native: $(CMXS)
	$(OCAMLOPT) $(LIBXS) $(CMXS) -o $(BINNAME).native

$(BINNAME).byte: $(CMOS)
	$(OCAMLC) $(LIBS) $(CMOS) -o $(BINNAME).byte


clean:
	rm -f $(CMOS) $(CMIS) $(CMXS) $(MLS:.ml=.o) $(TRASH)

purge: clean
	rm -f .depend $(BINNAME).native $(BINNAME).byte


depend: $(MLS)
	$(OCAMLDEP) $(MLS) >.depend


-include .depend

%.cmo: %.ml
	$(OCAMLC) $(LIBDIRS) -c $<

%.cmi: %.mli
	$(OCAMLC) $(LIBDIRS) -c $<

%.cmx: %.ml
	$(OCAMLOPT) $(LIBDIRS) -c $<

%.ml %.mli: %.mll
	$(OCAMLLEX) $<

%.ml %.mli: %.mly
	$(MENHIR) $<

%.pdf: %.tex
	pdflatex $<

%.tex: %.ott
	ott -i $< -o $@

%.ml: %.ott
	ott -i $< -o $@
