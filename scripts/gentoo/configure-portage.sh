#!/usr/bin/env bash
#
# This script automatically configures portage on a system it is run on.

set -o errexit -o pipefail -o nounset

PORTAGE_DIR=/etc/portage

if [[ $EUID != 0 ]]
then
    echo "Please run as root" > /dev/stderr
    exit 1
fi

if ! [[ -d "${PORTAGE_DIR}" ]]
then
    echo "No portage directory found!" > /dev/stderr
    exit 1
fi

# Packages needed to setup portage
#
# - app-portage/cpuid2cpuflags helps set the cpuflags
# - dev-vcs/git is required to sync repos
# - sys-apps/lshw is needed to detect hardware
PACKAGES=("app-portage/cpuid2cpuflags"
          "dev-vcs/git"
          "sys-apps/lshw"
         )

# Directoreis in the PORTAGE_DIR which should exits.
DIRS=("env/"
      "repos.conf/"
      "sets/"
      "package.use/"
      "patches/**/*/"
     )

# The files in PORTAGE_DIR which will be copied.
FILES=("env/*"
       "repos.conf/eselect-repo.conf"
       "sets/primary"
       "sets/secondary"
       "package.env"
       "package.license"
       "package.use/core"
       "package.use/llvm"
       "package.use/lua"
       "package.use/llvm"
       "package.use/misc"
       "package.use/python"
       "package.use/qemu"
       "package.use/ruby"
       "package.use/static"
       "package.use/steam"
       "patches/**/*/*.patch"
      )

# The M4 files which will generate configuration files in PORTAGE_DIR.
M4=("make.conf.m4"
    "package.use/cpuflags.m4"
    "package.use/videocards.m4"
   )


echo "[PKG]  ${PACKAGES[@]}"
MAKEOPTS="-j$(nproc)"                            \
emerge --ignore-default-opts -1uq ${PACKAGES[@]}

for path in ${DIRS[@]}
do
    for dir in etc/portage/${path[@]}
    do
        echo "[DIR]  ${dir#etc/portage/}"
        mkdir -p "${PORTAGE_DIR}/${dir#etc/portage/}"
    done
done

for path in ${FILES[@]}
do
    for file in etc/portage/${path[@]}
    do
        echo "[COPY] ${file#etc/portage/}"
        cp -f ${file} ${PORTAGE_DIR}/${file#etc/portage/}
    done
done

for path in ${M4[@]}
do
    echo "[M4]   ${path%.m4}"
    m4 m4/${path} > ${PORTAGE_DIR}/${path%.m4}
done

for repo in $(portageq get_repos /)
do
    if [[ "${repo}" != "gentoo" ]]
    then
        emaint sync -r "${repo}"
    fi
done

