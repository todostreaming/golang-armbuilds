#!/bin/bash
set -ex

# log infos about Linux kernel and OS system release
uname -a
cat /etc/*release

# we need this env var for the Go 1.5.x bootstrap build process
GOROOT_BOOTSTRAP=$HOME/go1.4

# install a pre-compiled Go 1.4.x tarball to bootstrap
GO_BOOTSTRAP_GOARM=${GO_BOOTSTRAP_GOARM:-64}
GO_BOOTSTRAP_VERSION=${GO_BOOTSTRAP_VERSION:-1.5.1}
rm -fr "$GOROOT_BOOTSTRAP"
mkdir -p "$GOROOT_BOOTSTRAP"
curl -sSL "https://github.com/hypriot/golang-armbuilds/releases/download/v${GO_BOOTSTRAP_VERSION}/go${GO_BOOTSTRAP_VERSION}.linux-arm${GO_BOOTSTRAP_GOARM}.tar.gz" | tar xz -C "$GOROOT_BOOTSTRAP" --strip-components=1

# fetch Go 1.5.x source tarball
GOARM=${GOARM:-64}
GO_VERSION=${GO_VERSION:-1.5.2}
rm -fr /usr/local/go
curl -sSL "https://storage.googleapis.com/golang/go${GO_VERSION}.src.tar.gz" | tar xz -C /usr/local

# now compile Go 1.5.x and package it as a tarball
pushd /usr/local/go/src
#time ./all.bash 2>&1
time ./make.bash 2>&1
cd ../..
tar --numeric-owner -czf "go${GO_VERSION}.linux-arm${GOARM}.tar.gz" go
popd
mv "/usr/local/go${GO_VERSION}.linux-arm${GOARM}.tar.gz" .

# cleanup
rm -fr "$GOROOT_BOOTSTRAP"
rm -fr /usr/local/go