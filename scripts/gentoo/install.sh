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

# Bootstrap some early packages which will be required.
MAKEOPTS="-j$(nproc)"                      \
uSE="default-ldd"                          \
emerge -1uq app-eselect/eselect-repository \
            app-portage/cpuid2cpuflags     \
            llvm-core/clang

# Configure portage
eselect repository enable guru
emaint sync -r guru
cp -r etc/portage /etc/
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/cpuflags
m4 m4/make.conf.m4 > /etc/portage/make.conf

# Do the main installation and cleanup
emerge -uqDN --ignore-default-opts @primary
emerge --depclean --ignore-default-opts
