export PREFIX := /usr/

.PHONY: all
all:
	$(info Usage: make install [PREFIX=/usr/])
	true

.PHONY: install

install: instantthemes
	$(info "INFO: install PREFIX: $(PREFIX)")
	mkdir -p $(DESTDIR)$(PREFIX)share/instantthemes
	cp -r colors $(DESTDIR)$(PREFIX)share/instantthemes/colors
	cp -r configs $(DESTDIR)$(PREFIX)share/instantthemes/configs
	cp -r dunst $(DESTDIR)$(PREFIX)share/instantthemes/dunst
	cp -r scripts $(DESTDIR)$(PREFIX)share/instantthemes/scripts
	cp -r utils $(DESTDIR)$(PREFIX)share/instantthemes/utils
	cp -r xresources $(DESTDIR)$(PREFIX)share/instantthemes/xresources
	install -Dm 755 instantthemes $(DESTDIR)$(PREFIX)bin/instantthemes

.PHONY: uninstall
uninstall:
	rm -r $(DESTDIR)$(PREFIX)share/instantthemes
	rm -f $(DESTDIR)$(PREFIX)bin/instantthemes
