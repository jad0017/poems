texfile ?= baristas.tex
pdffile := $(texfile:.tex=.pdf)

all: pdf

.PHONY: pdf
pdf:
	@pdflatex $(texfile)
	@mv $(pdffile) pdf/$(notdir $(pdffile))
	@$(MAKE) clean

.PHONY: clean
clean:
	@rm -f *.aux *.log

.PHONY: realclean
realclean: clean
	@rm -f pdf/$(pdffile)
