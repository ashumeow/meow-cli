PREFIX := /c/
VERSION := 1.0.0

deb:
	mkdir -p target/build$(PREFIX)/bin
	cp bin/* target/build$(PREFIX)/bin
	fpm -p target -C target/build -s dir -t deb -n meow-cli -v $(VERSION) -a all -d curl .

clean:
	rm -rf target

install:
	cp meow-cli $(DESTDIR)$(PREFIX)/meow-cli

uninstall:
	rm $(DESTDIR)$(PREFIX)/meow-cli

.PHONY: deb clean install uninstall
