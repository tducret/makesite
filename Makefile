site:
	./makesite.py

serve: site
	echo Running Python3 http.server ...
	python3 -m http.server --directory docs/