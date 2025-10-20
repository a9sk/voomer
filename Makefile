build:
	v -prod -o bin/zoomer src

run:
	./bin/zoomer

install:
	sudo cp bin/zoomer /usr/local/bin/
