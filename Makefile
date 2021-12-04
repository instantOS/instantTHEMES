export PREFIX := /usr/

.PHONY: all
all:
	$(info Usage: make install [PREFIX=/usr/])
	true

.PHONY: install

imosid:
	find -regex './themes/.*/dotfiles/.*/.*' -exec imosid compile "{}" \;

install:
	$(info "INFO: install PREFIX: $(PREFIX)")
	mkdir -p $(DESTDIR)$(PREFIX)share/instantthemes
	cp -r scripts $(DESTDIR)$(PREFIX)share/instantthemes/
	cp -r themes $(DESTDIR)$(PREFIX)share/instantthemes/
	cp -r utils $(DESTDIR)$(PREFIX)share/instantthemes/
	install -Dm 755 instantthemes.sh $(DESTDIR)$(PREFIX)bin/instantthemes

.PHONY: uninstall
uninstall:
	rm -r $(DESTDIR)$(PREFIX)share/instantthemes
	rm -f $(DESTDIR)$(PREFIX)bin/instantthemes
