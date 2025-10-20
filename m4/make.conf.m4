#  ____            _
# |  _ \ ___  _ __| |_ __ _  __ _  ___
# | |_) / _ \| '__| __/ _` |/ _` |/ _ \
# |  __/ (_) | |  | || (_| | (_| |  __/
# |_|   \___/|_|   \__\__,_|\__, |\___|
#                           |___/
#                  _                          __
#  _ __ ___   __ _| | _____   ___ ___  _ __  / _|
# | '_ ` _ \ / _` | |/ / _ \ / __/ _ \| '_ \| |_
# | | | | | | (_| |   <  __/| (_| (_) | | | |  _|
# |_| |_| |_|\__,_|_|\_\___(_)___\___/|_| |_|_|

esyscmd(./scripts/recomend-jobs.py)dnl

EMERGE_DEFAULT_OPTS="--ask --quiet --verbose --jobs=${JOBS_EMERGE} --load=${LAVG_EMERGE}"

FEATURES="candy parallel-fetch parallel-install"

ACCEPT_KEYWORDS="~amd64"
ACCEPT_LICENSE="@FREE"

DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
PORTAGE_TMPDIR="/var/tmp"
PORTAGE_NICENESS=2

MAKEOPTS="-j ${JOBS_MAKE} -l ${LAVG_MAKE}"

ifdef(CFG_FLAG_MACH, `', `define(CFG_FLAG_MACH, native)')dnl
ifdef(CFG_FLAG_OLVL, `', `define(CFG_FLAG_OLVL, -O2)')dnl
COMMON_FLAGS="-march=CFG_FLAG_MACH CFG_FLAG_OLVL -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=CFG_FLAG_MACH"

LC_MESSAGES=C.utf8
GRUB_PLATFORMS="efi-64"
GENTOO_MIRRORS="https://mirror.bytemark.co.uk/gentoo/ \
    https://www.irrorservice.org/sites/distfiles.gentoo.org/"
