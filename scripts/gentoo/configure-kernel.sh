#!/usr/bin/env bash
#
# This is a script to create a kernel configuration file for the linux kernel.
# Specifically the gentoo vanilla-kernel. The intention is to configure a
# kernel to support the required use-cases. Features which are not needed will
# also be removed if neccessary.
#
# TODO detect support for devices e.g. NVMe.

set -o errexit -o pipefail -o nounset

PORTAGE_DIR=/etc/portage
KERNEL_SRC=/usr/src/linux
KERNEL_CONFIG="${PORTAGE_DIR}/savedconfig/sys-kernel/vanilla-kernel"

if [[ $EUID != 0 ]]
then
    echo "Please run as root"
    exit 1
fi

zcat /proc/config.gz > "${KERNEL_CONFIG}"

CPU_VENDOR=$(lscpu --json | jq -r '.lscpu[] | select(.field == "Vendor ID:") | .data')

# The core configuration options.
#
# These options support systemd, perf, lvm, kexec, steam, etc. The config
# is generated for the vanilla-kernel so we suffix the kernel with "-dist".
# I have only condidered an X64 kernel.
${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"                    \
                             --set-str CONFIG_LOCALVERSION "-dist"        \
                             --enable  CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE \
                             --disable CONFIG_CC_OPTIMIZE_FOR_SIZE        \
                             --set-val CONFIG_HZ 1000                     \
                             --disable CONFIG_HZ_100                      \
                             --disable CONFIG_HZ_250                      \
                             --disable CONFIG_HZ_300                      \
                             --enable  CONFIG_HZ_1000                     \
                             --enable  CONFIG_IKCONFIG                    \
                             --enable  CONFIG_IKCONFIG_PROC               \
                             --enable  CONFIG_BLOCK                       \
                             --enable  CONFIG_BLK_DEV_BSGLIB              \
                             --enable  CONFIG_BLK_DEV_INITRD              \
                             --enable  CONFIG_BLK_DEV_MD                  \
                             --enable  CONFIG_BLK_DEV_DM                  \
                             --disable CONFIG_DM_DEBUG                    \
                             --enable  CONFIG_DM_SNAPSHOT                 \
                             --enable  CONFIG_DM_ZERO                     \
                             --enable  CONFIG_DM_UEVENT                   \
                             --enable  CONFIG_MD                          \
                             --enable  CONFIG_MD_LINEAR                   \
                             --enable  CONFIG_MD_BITMAP                   \
                             --disable CONFIG_MD_LLBITMAP                 \
                             --enable  CONFIG_MD_AUTODETECT               \
                             --enable  CONFIG_MD_BITMAP_FIE               \
                             --disable CONFIG_MD_RAID0                    \
                             --enable  CONFIG_MD_RAID1                    \
                             --disable CONFIG_MD_RAID10                   \
                             --disable CONFIG_MD_RAID456                  \
                             --enable  CONFIG_NET                         \
                             --enable  CONFIG_PACKET                      \
                             --module  CONFIG_CFG80211                    \
                             --disable CONFIG_SAMPLES                     \
                             --disable CONFIG_LIVEPATCH                   \
                             --enable  CONFIG_COREDUMP                    \
                             --enable  CONFIG_BINFMT_ELF                  \
                             --enable  CONFIG_BINFMT_SCRIPT               \
                             --enable  CONFIG_COMPAT_32BIT_TIME           \
                             --enable  CONFIG_INPUT_MISC                  \
                             --enable  CONFIG_INPUT_UINPUT                \
                             --enable  CONFIG_NAMESPACES                  \
                             --enable  CONFIG_USER_NS                     \
                             --enable  CONFIG_NET_NS                      \
                             --enable  CONFIG_IPV6                        \
                             --enable  CONFIG_SECCOMP                     \
                             --enable  CONFIG_DEVTMPFS                    \
                             --enable  CONFIG_TMPFS                       \
                             --enable  CONFIG_HUGETLBFS                   \
                             --enable  CONFIG_CGROUPS                     \
                             --enable  CONFIG_INOTIFY_USER                \
                             --enable  CONFIG_SIGNALFD                    \
                             --enable  CONFIG_TIMERFD                     \
                             --enable  CONFIG_EPOLL                       \
                             --enable  CONFIG_FRAME_POINTER               \
                             --enable  CONFIG_SYSFS                       \
                             --enable  CONFIG_FUSE_FS                     \
                             --enable  CONFIG_PROC_FS                     \
                             --enable  CONFIG_PROC_SYSCTL                 \
                             --enable  CONFIG_DMI_SYSFS                   \
                             --enable  CONFIG_UNIX                        \
                             --enable  CONFIG_FHANDLE                     \
                             --enable  CONFIG_BFP_SYSCALL                 \
                             --enable  CONFIG_KEXEC                       \
                             --enable  CONFIG_KEXEC_FILE                  \
                             --enable  CONFIG_UNICODE                     \
                             --enable  CONFIG_NLS                         \
                             --disable CONFIG_SCHED_OMIT_FRAME_POINTER    \
                             --disable CONFIG_PREEMPT_RT                  \
                             --module  CONFIG_NTSYNC

${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"              \
                             --enable  CONFIG_X86_MSR               \
                             --enable  CONFIG_X86_CPUID             \
                             --enable  CONFIG_X86_USER_SHADOW_STACK \
                             --enable  CONFIG_X86_NATIVE_CPU
# LLVM
# 
# Building the linux kernel with LLVM requires requires that make is invoked
# with LLVM=1. The /etc/portage/env/llvm file contains the setup to build the
# kernel using LLVM.
${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"        \
                             --enable  CONFIG_CFI             \
                             --enable  CONFIG_LTO             \
                             --enable  CONIG_LTO_CLANG        \
                             --disable CONFIG_LTO_CLANG_NONE  \
                             --enable  CONFIG_LTO_CLANG_FULL  \
                             --disable CONFIG_LTO_CLANG_THIN  \
                             --disable CONSIG_PROPELLER_CLANG \
                             --disable CONFIG_AUTOFDT_CLANG

# CPU
#
# If know that we don't have a specific CPU we can disable the 
# vendor specific options.

${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"        \
                             --disable CONFIG_CPU_SUP_HYGON   \
                             --disable CONFIG_CPU_SUP_CENTAUR \
                             --disable CONFIG_CPU_SUP_ZHAOXIN


if [[ "${CPU_VENDOR}" != "GenuineIntel" ]]
then
    ${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"      \
                                 --disable CONFIG_CPU_SUP_INTEL \
                                 --disable CONFIG_X86_MCE_INTEL \
                                 --disable CONFIG_KVM_INTEL     \
                                 --disable CONFIG_INTEL_IOMMU
fi

if [[ "${CPU_VENDOR}" != "AuthenticAMD" ]]
then
    ${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"        \
                                 --disable CONFIG_CPU_SUP_AMD     \
                                 --disable CONFIG_X86_MCE_AMD     \
                                 --disable CONFIG_AMD_MEM_ENCRYPT \
                                 --disable CONFIG_KVM_AMD         \
                                 --disable CONFIG_AMD_IOMMU
fi

# Compression
#
# Use ZSTD instead of the other alternatives. This algorithm seems to have
# a good balacne between speed and compression ration.
${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"             \
                             --disable CONFIG_KERNEL_GZIP          \
                             --disable CONFIG_KERNEL_BZIP2         \
                             --disable CONFIG_KERNEL_LZMA          \
                             --disable CONFIG_KERNEL_XZ            \
                             --disable CONFIG_KERNEL_LZO           \
                             --disable CONFIG_KERNEL_LZ4           \
                             --enable  CONFIG_KERNEL_ZSTD          \
                             --disable CONFIG_MODULE_COMPRESS_GZIP \
                             --disable CONFIG_MODULE_COMPRESS_XZ   \
                             --enable  CONFIG_MODULE_COMPRESS_ZSTD

# Filesystems
#
# The filesystesm used are EXT4, XFS and vFAT.
# Other file systems are not enabled.
${KERNEL_SRC}/scripts/config --file "${KERNEL_CONFIG}"               \
                             --disable CONFIG_EXT2_FS                \
                             --enable  CONFIG_EXT4_FS                \
                             --enable  CONFIG_EXT4_USE_FOR_EXT2      \
                             --enable  CONFIG_EXT4_FS_POSIX_ACL      \
                             --enable  CONFIG_EXT4_FS_SECURITY       \
                             --disable CONFIG_EXT4_DEBUG             \
                             --disable CONFIG_JBD2_DEBUG             \
                             --disable CONFIG_JFS_FS                 \
                             --enable  CONFIG_XFS_FS                 \
                             --enable  CONFIG_XFS_SUPPORT_V4         \
                             --enable  CONFIG_XFS_SUPPORT_ASCII_CI   \
                             --enable  CONFIG_XFS_QUOTA              \
                             --enable  CONFIG_XFS_POSIX_ACL          \
                             --enable  CONFIG_XFS_RT                 \
                             --enable  CONFIG_XFS_ONLINE_SCRUB       \
                             --disable CONFIG_XFS_ONLINE_SCRUB_STATS \
                             --enable  CONFIG_XFS_ONLINE_REPAIR      \
                             --disable CONFIG_XFS_WARN               \
                             --disable CONFIG_XFS_DEBUG              \
                             --disable CONFIG_GFS2_FS                \
                             --disable CONFIG_OCFS2_FS               \
                             --disable CONFIG_BTRFS_FS               \
                             --disable CONFIG_NILFS2_FS              \
                             --disable CONFIG_F2FS_FS                \
                             --disable CONFIG_ZONEFS_FS              \
                             --disable CONFIG_MSDOS_FS               \
                             --module  CONFIG_VFAT_FS                \
                             --disable CONFIG_EXFAT_FS               \
                             --disable CONFIG_NTFS3_FS               \
                             --disable CONFIG_NTFS_FS                \
                             --disable CONFIG_ORANGEFS_FS            \
                             --disable CONFIG_AFFS_FS                \
                             --disable CONFIG_ADFS_FS                \
                             --disable CONFIG_ECRYPT_FS              \
                             --disable CONFIG_HFS_FS                 \
                             --disable CONFIG_HFSPLUS_FS
