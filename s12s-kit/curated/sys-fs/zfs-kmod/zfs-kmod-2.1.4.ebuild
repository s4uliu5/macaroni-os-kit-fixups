# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic linux-mod toolchain-funcs

DESCRIPTION="Linux ZFS kernel module for sys-fs/zfs"
HOMEPAGE="https://github.com/openzfs/zfs"

MY_PV="${PV/_rc/-rc}"
SRC_URI="https://github.com/openzfs/zfs/releases/download/zfs-${MY_PV}/zfs-${MY_PV}.tar.gz"
S="${WORKDIR}/zfs-${PV%_rc?}"
ZFS_KERNEL_COMPAT="5.17"

#  increments minor eg 5.14 -> 5.15, and still supports override.
ZFS_KERNEL_DEP="${ZFS_KERNEL_COMPAT_OVERRIDE:-${ZFS_KERNEL_COMPAT}}"
ZFS_KERNEL_DEP="${ZFS_KERNEL_DEP%%.*}.$(( ${ZFS_KERNEL_DEP##*.} + 1))"

KEYWORDS=""

LICENSE="CDDL MIT debug? ( GPL-2+ )"
SLOT="0/${PVR}"
IUSE="custom-cflags debug +rootfs"

RDEPEND="${DEPEND}
	!sys-kernel/spl
"

BDEPEND="
	dev-lang/perl
	virtual/awk
"

RESTRICT="debug? ( strip ) test"

DOCS=( AUTHORS COPYRIGHT META README.md )

pkg_setup() {
	CONFIG_CHECK="
		!DEBUG_LOCK_ALLOC
		EFI_PARTITION
		MODULES
		!PAX_KERNEXEC_PLUGIN_METHOD_OR
		!TRIM_UNUSED_KSYMS
		ZLIB_DEFLATE
		ZLIB_INFLATE
	"

	use debug && CONFIG_CHECK="${CONFIG_CHECK}
		FRAME_POINTER
		DEBUG_INFO
		!DEBUG_INFO_REDUCED
	"

	use rootfs && \
		CONFIG_CHECK="${CONFIG_CHECK}
			BLK_DEV_INITRD
			DEVTMPFS
	"

	kernel_is -lt 5 && CONFIG_CHECK="${CONFIG_CHECK} IOSCHED_NOOP"

	local kv_major_max kv_minor_max zcompat
	zcompat="${ZFS_KERNEL_COMPAT_OVERRIDE:-${ZFS_KERNEL_COMPAT}}"
	kv_major_max="${zcompat%%.*}"
	zcompat="${zcompat#*.}"
	kv_minor_max="${zcompat%%.*}"
	kernel_is -le "${kv_major_max}" "${kv_minor_max}" || die \
		"Linux ${kv_major_max}.${kv_minor_max} is the latest supported version"

	kernel_is -ge 3 10 || die "Linux 3.10 or newer required"

	linux-mod_pkg_setup
}

src_prepare() {
	default

	# Run unconditionally (bug #792627)
	eautoreconf

	# Set module revision number
	sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-funtoo/" META || die "Could not set Funtoo release"
}

src_configure() {
	set_arch_to_kernel

	use custom-cflags || strip-flags

	filter-ldflags -Wl,*

	# Set CROSS_COMPILE in the environment.
	# This allows the user to override it via make.conf or via a local Makefile.
	# https://bugs.gentoo.org/811600
	export CROSS_COMPILE=${CROSS_COMPILE-${CHOST}-}

	local myconf=(
		HOSTCC="$(tc-getBUILD_CC)"
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=kernel
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		$(use_enable debug)
	)

	econf "${myconf[@]}"
}

src_compile() {
	set_arch_to_kernel

	myemakeargs=(
		HOSTCC="$(tc-getBUILD_CC)"
		V=1
	)

	emake "${myemakeargs[@]}"
}

src_install() {
	set_arch_to_kernel

	myemakeargs+=(
		DEPMOD=:
		# INSTALL_MOD_PATH ?= $(DESTDIR) in module/Makefile
		DESTDIR="${D}"
	)

	emake "${myemakeargs[@]}" install

	einstalldocs
}

pkg_postinst() {
	linux-mod_pkg_postinst

	if has_version sys-boot/grub; then
		ewarn "This version of OpenZFS includes support for new feature flags"
		ewarn "that are incompatible with previous versions. GRUB2 support for"
		ewarn "/boot with the new feature flags is not yet available."
		ewarn "Do *NOT* upgrade root pools to use the new feature flags."
		ewarn "Any new pools will be created with the new feature flags by default"
		ewarn "and will not be compatible with older versions of OpenZFS. To"
		ewarn "create a newpool that is backward compatible wih GRUB2, use "
		ewarn
		ewarn "zpool create -o compatibility=grub2 ..."
		ewarn
		ewarn "Refer to /usr/share/zfs/compatibility.d/grub2 for list of features."
	fi
}
