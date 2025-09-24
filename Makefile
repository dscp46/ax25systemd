# Extract package name and version from DEBIAN/control
TITLE := $(shell grep '^Description:' DEBIAN/control | sed 's/^Description: //')
PACKAGE := $(shell awk '/^Package:/ {print $$2}' DEBIAN/control)
VERSION := $(shell awk '/^Version:/ {print $$2}' DEBIAN/control)
DEBFILE := $(PACKAGE)_$(VERSION).deb

MAGIC_TITLE := __PROJECT_TITLE__
MAGIC_VERSION := __PROJECT_VER__

# Default root location for install target
ROOTLOC ?=

# Manpages list
MANPAGES := $(patsubst ./%,%,$(wildcard doc/*))
MANDEST := $(ROOTLOC)/usr/share/man

# === Default target ===
.PHONY: all
all:
	@echo "Available targets:"
	@echo "  install   - Install files into the system (uses ROOTLOC prefix if set)"
	@echo "  uninstall - Remove installed files"
	@echo "  build-deb - Build a .deb package"
	@echo "  lint      - Run lintian on the built .deb package"

# === Install target ===
.PHONY: install
install:
	install -Dm644 ax25@.service $(ROOTLOC)/usr/lib/systemd/system/ax25@.service
	install -Dm644 kissports $(ROOTLOC)/etc/ax25/kissports
	install -Dm755 axdown $(ROOTLOC)/usr/sbin/axdown
	install -Dm755 axup $(ROOTLOC)/usr/sbin/axup
	install -Dm755 axmd5 $(ROOTLOC)/usr/bin/axmd5
	install -d $(ROOTLOC)/usr/share/kissinit
	install -Dm755 kissinit/* $(ROOTLOC)/usr/share/kissinit/
	install -d $(ROOTLOC)/usr/share/doc/$(PACKAGE)
	install -m644 DEBIAN/copyright $(ROOTLOC)/usr/share/doc/$(PACKAGE)/copyright
	gzip -9nc DEBIAN/changelog > $(ROOTLOC)/usr/share/doc/$(PACKAGE)/changelog.gz
	install -d $(MANDEST)/man1
	install -d $(MANDEST)/man5
	@for manpage in $(MANPAGES); do \
		ext=$${manpage##*\.}; \
		destdir=$(MANDEST)/man$${ext}; \
		sed -e 's/$(MAGIC_TITLE)/$(TITLE)/g' \
		    -e 's/$(MAGIC_VERSION)/$(VERSION)/g' \
		    $${manpage} | gzip -9nc > $${destdir}/$$(basename $${manpage}).gz; \
	done

# === Uninstall target ===
.PHONY: uninstall
uninstall:
	rm -f /usr/lib/systemd/system/ax25@.service
	rm -f /etc/ax25/kissports
	rm -f /usr/sbin/axdown
	rm -f /usr/sbin/axup
	rm -f /usr/bin/axmd5
	rm -rf /usr/share/kissinit
	rm -rf /usr/share/doc/$(PACKAGE)
	@for manpage in $(MANPAGES); do \
		ext=$${manpage##*\.}; \
		destdir=$(MANDEST)/man$${ext}; \
		rm -f $${destdir}/$$(basename $${manpage}).gz; \
	done

# === Build-deb target ===
.PHONY: build-deb
build-deb: clean-build
	mkdir -p build
	# Run install under fakeroot so ownership is root:root in package
	fakeroot $(MAKE) ROOTLOC=./build install
	cp -r DEBIAN build/
	# Fix some Lintian warnings
	rm -f build/DEBIAN/copyright
	rm -f build/DEBIAN/changelog
	fakeroot dpkg-deb --build build $(DEBFILE)

# === Lint target ===
.PHONY: lint
lint: $(DEBFILE)
	lintian $(DEBFILE)

# === Clean helper for builds ===
.PHONY: clean-build
clean-build:
	rm -rf build
	rm -f $(DEBFILE)

