#! /usr/bin/env bash
#
# This is an install script for setting up Gentoo. It is intended to be run on
# a fresh stage3 tarball. It may be necessary to sync and update before running
# this script.
#
# TODO add cmdline options.

set -o errexit -o pipefail -o nounset

if [ "${EUID}" -ne 0 ]
then
    echo "Pleas run $0 as root"
    exit
fi

# Packages which must be installed before we configure portage
# to correctly bootstrap the actual installation.
PKGS=("app-portage/cpuid2cpuflags"
      "dev-lang/rust-bin"
      "dev-vcs/git"
      "llvm-core/clang"
      "sys-apps/lshw"
     )

echo "Installing pakcages required for bootstrapping the system" > /dev/stderr
MAKEOPTS="-j$(nproc)"     \
USE="default-ldd"         \
emerge --ignore-default-opts -1uq "${PKGS[@]}"

scripts/gentoo/configure-portage.sh

echo "Install..." > /dev/stderr
# Do the main installation and cleanup
emerge --ignore-default-opts -uqDN @primary @secondary
emerge --ignore-default-opts --depclean
