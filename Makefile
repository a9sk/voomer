build:
	v -prod -o bin/zoomer .

run:
	make build && ./bin/zoomer

install:
	sudo cp bin/zoomer /usr/local/bin/
