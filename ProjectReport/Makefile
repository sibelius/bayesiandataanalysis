all:
	pdflatex projectReport.tex
	bibtex projectReport
	pdflatex projectReport.tex
	pdflatex projectReport.tex
	open projectReport.pdf
	rm -rf *.aux *.log *.bak *.out *.bbl *.blg

clean:
	rm -rf *.aux *.log *.bak *.out *.bbl *.blg
