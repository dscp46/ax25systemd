# ax25systemd
Losely based on https://github.com/la5nta/pat/tree/master/share

## Known issues
https://github.com/F4FXL/ax25systemd/issues/2

## Instructions
You can install this package either by running `make install`.

A debian binary package can be built by running `make build-deb`.

# Dependencies
The deb package already cares of dependencies for you.

Prerequisite for this package is `ax25-tools`, `awk`.

To build the package, you'll need `coreutils`, `dpkg`, and `fakeroot` on top of the prerequisites.
Optionally, you'll need `lintian` to check the built package.
