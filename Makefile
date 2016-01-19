texfile ?= baristas.tex
pdffile := $(notdir $(texfile:.tex=.pdf))
psfile  := $(notdir $(texfile:.tex=.ps))

all: pdf

.PHONY: ps
ps: pdf
	@pdf2ps pdf/$(pdffile) >pdf/$(psfile)

.PHONY: pdf
pdf:
	@pdflatex $(texfile)
	@mv $(pdffile) pdf/$(pdffile)
	@$(MAKE) clean

.PHONY: clean
clean:
	@rm -f *.aux *.log

.PHONY: realclean
realclean: clean
	@rm -f pdf/$(pdffile)
