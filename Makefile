TARGETS = calibration.pdf
# directory to search for LSST references, probably from git@github.com:lsst-pst/references
LSST_REFERENCES_DIR = \$(HOME)/LSST/References

DEPS_DIR = .deps
LATEXMK = latexmk -silent -recorder -use-make -deps \
                  -e 'warn qq(In Makefile, turn off custom dependencies\n);' \
                  -e '@cus_dep_list = ();' \
                  -e 'show_cus_dep();'

all : $(TARGETS)
$(foreach file,$(TARGETS),$(eval -include $(DEPS_DIR)/$(file)P))

$(DEPS_DIR) :
	mkdir $@
#
# Glossaries
#
%.acr : %.acn
	makeglossaries $*.acn
%.gls : %.glo
	makeglossaries $*.glo

%.pdf : %.tex
	mkdir -p $(DEPS_DIR)
	export BIBINPUTS=$(LSST_REFERENCES_DIR); \
	$(LATEXMK) -pdf -pdflatex="pdflatex -interaction=nonstopmode" -deps-out=$(DEPS_DIR)/$@P $< 2>&1 | \
			tex-fix-log-linebreaks | \
			grep -v 'Not recognizing known sRGB profile that has been edited'


clean:
	latexmk -CA
	$(RM) *.acn *.acr *.alg *.bbl *.glg *.glo *.gls *.xdy *.run.xml
	$(RM) *~
	$(RM) -r $(DEPS_DIR)
