#!/bin/bash -e
# Manually build OpenSSL. The openssl crate requires 1.0.2+, but Travis CI
# only includes 1.0.0.
wget https://www.openssl.org/source/openssl-1.1.1.tar.gz
tar xzf openssl-1.1.1.tar.gz
cd openssl-1.1.1
./config --prefix=/usr/local shared
make >/dev/null
sudo make install >/dev/null
sudo ldconfig
cd ..
sudo apt-get update
sudo apt-get install -qq gcc-arm-linux-gnueabihf
rustup target add armv7-unknown-linux-gnueabihf

sudo apt-get install libmagickwand-dev
sudo apt-get install libudev-dev

SYSROOT=/build/root

export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
export PKG_CONFIG_ALLOW_CROSS=1

sudo find / -type f -name "libudev.pc"
cross test
cross build --target armv7-unknown-linux-gnueabihf
cargo deb --target x86_64-unknown-linux-gnu
# cargo deb --no-build --variant=armv7