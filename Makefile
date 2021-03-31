export PREFIX := /usr/

SUBDIRS := utils/ data/default/
SUBDIRS := colors/ configs/ dunst/ scripts/ utils/ xresources/

.PHONY: all
all:
	$(info Usage: make install [PREFIX=/usr/])
	true

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) install -C $@

.PHONY: install
install: instantthemes $(SUBDIRS)
	$(info "INFO: install PREFIX: $(PREFIX)")
	mkdir -p $(DESTDIR)$(PREFIX)share/instantthemes $(DESTDIR)$(PREFIX)share/applications/
	install -Dm 755 instantthemes $(DESTDIR)$(PREFIX)bin/instantthemes

.PHONY: uninstall
uninstall:
	rm -r $(DESTDIR)$(PREFIX)share/instantthemes
	rm -f $(DESTDIR)$(PREFIX)bin/instantthemes
