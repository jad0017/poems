texfile ?= baristas.tex
pdffile := $(notdir $(texfile:.tex=.pdf))
psfile  := $(notdir $(texfile:.tex=.ps))
txtfile := $(notdir $(texfile:.tex=.txt))

all: pdf

.PHONY: ps
ps: pdf
	@pdf2ps pdf/$(pdffile) >pdf/$(psfile)

.PHONY: pdf
pdf:
	@mkdir -p pdf
	@pdflatex $(texfile)
	@mv $(pdffile) pdf/$(pdffile)
	@$(MAKE) clean

.PHONY: txt
txt: pdf
	@pdftotext -nopgbreak pdf/$(pdffile) pdf/$(txtfile)
	@sed -ri -e 's/\x0C//g' -e '/^[[:digit:]]$$/d' pdf/$(txtfile)

.PHONY: clean
clean:
	@rm -f *.aux *.log

.PHONY: realclean
realclean: clean
	@rm -f pdf/$(pdffile)