define DESCR
Description: Torrent search and start using KAT and transmission-remote
 CLI and standalone webapp
endef
export DESCR
SHELL := bash
REL := .release

all:
install: uninstall
	-mkdir -p $(DESTDIR)/usr/share/kat-get
	cp -r public kat-get kat-get.service $(DESTDIR)/usr/share/kat-get
uninstall:
	-rm -rf $(DESTDIR)/usr/share/kat-get
start:
	./kat-get -d
cli:
	./kat-get MotoGP
# Release
tag:
	@git status | grep -q 'nothing to commit' || (echo Worktree dirty; exit 1)
	@echo 'Chose old tag to follow: '; \
	select OLD in `git tag`; do break; done; \
	export TAG; \
	read -p 'Please Enter new tag name: ' TAG; \
	echo Adding git tag $$TAG; \
	echo "kat-get ($$TAG)" > changelog; \
	if [ -n "$$OLD" ]; then \
	  git log --pretty=format:"  * %h %an %s" $$OLD.. >> changelog; \
	  echo >> changelog; \
	else \
	  echo '  * Initial release' >> changelog; \
	fi; \
	echo " -- SZABO Gergely <szg@subogero.com>  `date -R`" >> changelog; \
	git tag -a -F changelog $$TAG HEAD; \
	rm changelog
utag:
	TAG=`git name-rev --tags HEAD | sed -rn 's|HEAD tags/([^^]+).*|\1|p'`; \
	[ "$$TAG" ] && git tag -d $$TAG
tarball:
	export TAG=`git name-rev --tags HEAD | sed -rn 's|HEAD tags/([^^]+).*|\1|p'`; \
	$(MAKE) balls
balls:
	mkdir -p $(REL)/kat-get-$(TAG); \
	cp -rt $(REL)/kat-get-$(TAG) *; \
	cd $(REL); \
	tar -czf kat-get_$(TAG).tar.gz kat-get-$(TAG)
deb: tarball
	export TAG=`git name-rev --tags HEAD | sed -rn 's|HEAD tags/([^^]+).*|\1|p'`; \
	export DEB=$(REL)/kat-get-$${TAG}/debian; \
	$(MAKE) debs
debs:
	-rm $(REL)/*.deb
	cp -f $(REL)/kat-get_$(TAG).tar.gz $(REL)/kat-get_$(TAG).orig.tar.gz
	mkdir -p $(DEB)
	echo 'Source: kat-get'                               >$(DEB)/control
	echo 'Section: web'                                 >>$(DEB)/control
	echo 'Priority: optional'                           >>$(DEB)/control
	echo 'Maintainer: SZABO Gergely <szg@subogero.com>' >>$(DEB)/control
	echo 'Build-Depends: debhelper, curl'               >>$(DEB)/control
	echo 'Standards-version: 3.8.4'                     >>$(DEB)/control
	echo                                                >>$(DEB)/control
	echo 'Package: kat-get'                             >>$(DEB)/control
	echo 'Architecture: all'                            >>$(DEB)/control
	echo 'Depends: $${shlibs:Depends}, $${misc:Depends}, libmojolicious-perl, transmission-daemon' >>$(DEB)/control
	echo "$$DESCR"                                      >>$(DEB)/control
	echo 'Copyright 2016 SZABO Gergely <szg@subogero.com>' >$(DEB)/copyright
	echo 'License: GNU GPL v2'                            >>$(DEB)/copyright
	echo ' See /usr/share/common-licenses/GPL-2'          >>$(DEB)/copyright
	echo usr/share/kat-get >$(DEB)/kat-get.dirs
	echo 7 > $(DEB)/compat
	for i in `git tag | sort -rg`; do git show $$i | sed -n '/^kat-get/,/^ --/p'; done \
	| sed -r 's/^kat-get \((.+)\)$$/kat-get (\1-1) UNRELEASED; urgency=low/' \
	| sed -r 's/^(.{,79}).*/\1/' \
	> $(DEB)/changelog
	echo '#!/usr/bin/make -f' > $(DEB)/rules
	echo '%:'                >> $(DEB)/rules
	echo '	dh $$@'          >> $(DEB)/rules
	cp -t $(DEB) prerm
	cp -t $(DEB) postinst
	chmod 755 $(DEB)/rules
	mkdir -p $(DEB)/source
	echo '3.0 (quilt)' > $(DEB)/source/format
	@cd $(REL)/kat-get-$(TAG) && \
	echo && echo List of PGP keys for signing package: && \
	gpg -K | grep uid && \
	read -ep 'Enter key ID (part of name or alias): ' KEYID; \
	if [ "$$KEYID" ]; then \
	  dpkg-buildpackage -k$$KEYID; \
	else \
	  dpkg-buildpackage -us -uc; \
	fi
	fakeroot alien -kr --scripts $(REL)/*.deb; mv *.rpm $(REL)
release: tag deb
