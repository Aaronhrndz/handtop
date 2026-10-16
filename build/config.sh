# Shared build configuration. Sourced by build scripts.
TOP="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." && pwd)"   # absolute, independent of $HOME/sudo
WORK="${WORK:-$TOP/work}"

RELEASE_VERSION="0.1.0"            # used in the image name when not building from a git checkout

ROCKNIX_VERSION="20261001"
ROCKNIX_IMAGE="ROCKNIX-H700.aarch64-${ROCKNIX_VERSION}-DDR4.img.gz"
ROCKNIX_URL="https://github.com/ROCKNIX/distribution/releases/download/${ROCKNIX_VERSION}/${ROCKNIX_IMAGE}"

ROCKNIX_DL="$WORK/download"        # downloaded image + checksum
ROCKNIX_EX="$WORK/rocknix"         # extracted hardware layer

DEBIAN_SUITE="trixie"
DEBIAN_MIRROR="https://deb.debian.org/debian"

ROOTFS="$WORK/rootfs"              # Debian root filesystem being built
KVER="7.2.0"                       # ROCKNIX kernel version (must match modules/)
# Hardware video decoder module (06b-cedrus.sh): same kernel source + compiler as ROCKNIX
LINUX_VERSION="7.2"
LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${LINUX_VERSION}.tar.xz"
LINUX_SHA256="f9fef3d14c0df53819026f4be74459835c2a0b0dcbf5b5bbd9ea19f0829402b3"
KTOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/15.2.rel1/binrel/arm-gnu-toolchain-15.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
KTOOLCHAIN_SHA256="9a685b335bd709d683a8c782253c37e8c36c10e6924e59e39d4769b02132eb43"
CMA_SIZE="256M"                    # contiguous memory for the decoder (no IOMMU, see docs/video-decode.md)

# Target system identity
HOSTNAME_TARGET="rg35xxh"
USER_NAME="rg"
USER_DEFAULT_PASSWORD="rg35xxh"    # documented default; SSH stays off until the user sets their own (Apps -> Enable SSH)
LOCALE="en_US.UTF-8"
TIMEZONE="Etc/UTC"                 # change on the device: sudo timedatectl set-timezone <Area/City>

ROOT_LABEL="rg35xxh-root"
BOOT_LABEL="RG35XXHBOOT"           # FAT label, max 11 chars

# Optional extra CA for TLS-inspecting proxies (used only during the build, never shipped).
BUILD_EXTRA_CA="${BUILD_EXTRA_CA:-}"

# nwg-drawer (not packaged in trixie; cross-compiled from source)
NWG_DRAWER_VERSION="v0.7.5"
GO_TOOLCHAIN="${GO_TOOLCHAIN:-$WORK/tools/go/bin/go}"   # Go >= 1.25 on the build host

source "$TOP/build/lib/safety.sh"

# Image layout
IMAGE_NAME="handtop"
DISK_ID="0x52473335"               # MBR disk id ("RG35"); root=PARTUUID=52473335-02
BOOT_START_MIB=16                  # U-Boot lives in the first 16 MiB (SPL at 8 KiB)
BOOT_SIZE_MIB=256
DEFAULT_DTB="sun50i-h700-anbernic-rg35xx-h.dtb"
