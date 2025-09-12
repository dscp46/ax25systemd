# Extract package name and version from DEBIAN/control
PACKAGE := $(shell awk '/^Package:/ {print $$2}' DEBIAN/control)
VERSION := $(shell awk '/^Version:/ {print $$2}' DEBIAN/control)
DEBFILE := $(PACKAGE)_$(VERSION).deb

# Default root location for install target
ROOTLOC ?=

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
	install -d $(ROOTLOC)/usr/share/kissinit
	install -Dm755 kissinit/* $(ROOTLOC)/usr/share/kissinit/

# === Uninstall target ===
.PHONY: uninstall
uninstall:
	rm -f /usr/lib/systemd/system/ax25@.service
	rm -f /etc/ax25/kissports
	rm -f /usr/sbin/axdown
	rm -f /usr/sbin/axup
	rm -rf /usr/share/kissinit

# === Build-deb target ===
.PHONY: build-deb
build-deb: clean-build
	mkdir -p build
	$(MAKE) ROOTLOC=./build install
	cp -r DEBIAN build/
	dpkg-deb --build build $(DEBFILE)

# === Lint target ===
.PHONY: lint
lint: $(DEBFILE)
	lintian $(DEBFILE)

# === Clean helper for builds ===
.PHONY: clean-build
clean-build:
	rm -rf build
	rm -f $(DEBFILE)
