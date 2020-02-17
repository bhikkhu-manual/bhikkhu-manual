FILE_HANDBOOK=main_handbook
FILE_CHANTING=main_chanting

LATEX=lualatex
BIBTEX=bibtex

LATEX_OPTS=-interaction=nonstopmode -halt-on-error -synctex=1

all:
	@echo "Specify the make target, such as 'handbook' or 'chanting'."

dist:
	./helpers/dist.sh

handbook:
	cat $(FILE_HANDBOOK).fir | \
		sed '/\\contentsfinish/d' | \
		sort > $(FILE_HANDBOOK).fir.tmp
	echo '\\contentsfinish' >> $(FILE_HANDBOOK).fir.tmp
	mv $(FILE_HANDBOOK).fir.tmp $(FILE_HANDBOOK).fir
	$(LATEX) $(LATEX_OPTS) $(FILE_HANDBOOK).tex;

sass-watch:
	node-sass -w ./assets/sass -o ./assets/stylesheets

preview-handbook:
	latexmk -pvc $(FILE_HANDBOOK).tex

