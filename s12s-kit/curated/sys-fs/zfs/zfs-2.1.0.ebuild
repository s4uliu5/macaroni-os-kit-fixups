# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
DISTUTILS_USE_SETUPTOOLS=manual
PYTHON_COMPAT=( python3+ )

inherit autotools bash-completion-r1 distutils-r1 flag-o-matic linux-info pam systemd toolchain-funcs udev usr-ldscript

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="https://github.com/openzfs/zfs"

MY_P="${P/_rc/-rc}"
SRC_URI="https://github.com/openzfs/${PN}/releases/download/${MY_P}/${MY_P}.tar.gz"
S="${WORKDIR}/${P%_rc?}"
KEYWORDS=""

LICENSE="BSD-2 CDDL MIT"
# just libzfs soname major for now.
# possible candidates: libuutil, libzpool, libnvpair. Those do not provide stable abi, but are considered.
# see libsoversion_check() below as well
SLOT="0/5"
IUSE="custom-cflags debug kernel-builtin libressl minimal nls pam python +rootfs test-suite static-libs"

DEPEND="
	net-libs/libtirpc[static-libs?]
	sys-apps/util-linux[static-libs?]
	sys-libs/zlib[static-libs(+)?]
	virtual/libudev[static-libs(-)?]
	libressl? ( dev-libs/libressl:0=[static-libs?] )
	!libressl? ( dev-libs/openssl:0=[static-libs?] )
	!minimal? ( ${PYTHON_DEPS} )
	pam? ( sys-libs/pam )
	python? (
		virtual/python-cffi[${PYTHON_USEDEP}]
	)
"

BDEPEND="virtual/awk
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	python? (
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
"

# awk is used for some scripts, completions, and the Dracut module
RDEPEND="${DEPEND}
	!kernel-builtin? ( ~sys-fs/zfs-kmod-${PV} )
	!prefix? ( virtual/udev )
	sys-fs/udev-init-scripts
	virtual/awk
	rootfs? (
		app-arch/cpio
		app-misc/pax-utils
		!<sys-kernel/genkernel-3.5.1.1
	)
	test-suite? (
		sys-apps/kmod[tools]
		sys-apps/util-linux
		sys-devel/bc
		sys-block/parted
		sys-fs/lsscsi
		sys-fs/mdadm
		sys-process/procps
	)
"

REQUIRED_USE="
	!minimal? ( ${PYTHON_REQUIRED_USE} )
	python? ( !minimal )
	test-suite? ( !minimal )
"

RESTRICT="test"

PATCHES=( "${FILESDIR}/2.0.4-scrub-timers.patch" )

pkg_setup() {
	if use kernel_linux; then
		linux-info_pkg_setup

		if ! linux_config_exists; then
			ewarn "Cannot check the linux kernel configuration."
		else
			if use test-suite; then
				if linux_chkconfig_present BLK_DEV_LOOP; then
					eerror "The ZFS test suite requires loop device support enabled."
					eerror "Please enable it:"
					eerror "    CONFIG_BLK_DEV_LOOP=y"
					eerror "in /usr/src/linux/.config or"
					eerror "    Device Drivers --->"
					eerror "        Block devices --->"
					eerror "            [X] Loopback device support"
				fi
			fi
		fi
	fi
}

libsoversion_check() {

	local bugurl libzfs_sover
	bugurl="https://bugs.gentoo.org/enter_bug.cgi?form_name=enter_bug&product=Gentoo+Linux&component=Current+packages"

	libzfs_sover="$(grep 'libzfs_la_LDFLAGS += -version-info' lib/libzfs/Makefile.am \
		| grep -Eo '[0-9]+:[0-9]+:[0-9]+')"
	libzfs_sover="${libzfs_sover%%:*}"

	if [[ ${libzfs_sover} -ne $(ver_cut 2 ${SLOT}) ]]; then
		echo
		eerror "BUG BUG BUG BUG BUG BUG BUG BUG"
		eerror "ebuild subslot does not match libzfs soversion!"
		eerror "libzfs soversion: ${libzfs_sover}"
		eerror "ebuild value: $(ver_cut 2 ${SLOT})"
		eerror "This is a bug in the ebuild, please use the following URL to report it"
		eerror "${bugurl}&short_desc=${CATEGORY}%2F${P}+update+subslot"
		echo
	fi
}

src_prepare() {
	default
	libsoversion_check

	# Run unconditionally (Gentoo bug #792627)
	eautoreconf

	# Set revision number
	sed -i "s/\(Release:\)\(.*\)1/\1\2${PR}-funtoo/" META || die "Could not set Funtoo release"

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_prepare
		popd >/dev/null || die
	fi

	# prevent errors showing up on zfs-mount stop, #647688
	# openrc will unmount all filesystems anyway.
	sed -i "/^ZFS_UNMOUNT=/ s/yes/no/" "etc/default/zfs.in" || die
}

src_configure() {
	use custom-cflags || strip-flags
	use minimal || python_setup

	local myconf=(
		--bindir="${EPREFIX}/bin"
		--enable-shared
		--disable-systemd
		--enable-sysvinit
		--localstatedir="${EPREFIX}/var"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		--with-dracutdir="${EPREFIX}/usr/lib/dracut"
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		--with-udevdir="$(get_udevdir)"
		--with-pamconfigsdir="${EPREFIX}/unwanted_files"
		--with-pammoduledir="$(getpam_mod_dir)"
		--with-vendor=gentoo
		$(use_enable debug)
		$(use_enable nls)
		$(use_enable pam)
		$(use_enable python pyzfs)
		$(use_enable static-libs static)
		$(usex minimal --without-python --with-python="${EPYTHON}")
	)

	econf "${myconf[@]}"
}

src_compile() {
	default
	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_compile
		popd >/dev/null || die
	fi
}

src_install() {
	default

	gen_usr_ldscript -a nvpair uutil zfsbootenv zfs zfs_core zpool

	use pam && { rm -rv "${ED}/unwanted_files" || die ; }

	use test-suite || { rm -r "${ED}/usr/share/zfs" || die ; }

	if ! use static-libs; then
		find "${ED}" -name '*.la' -delete || die
	fi

	dobashcomp contrib/bash_completion.d/zfs
	bashcomp_alias zfs zpool

	# strip executable bit from conf.d file
	fperms 0644 /etc/conf.d/zfs

	if use python; then
		pushd contrib/pyzfs >/dev/null || die
		distutils-r1_src_install
		popd >/dev/null || die
	fi

	# enforce best available python implementation
	use minimal || python_fix_shebang "${ED}/bin"
}

pkg_postinst() {
	if [[ -e "${EROOT}/etc/runlevels/boot/zfs" ]]; then
		einfo 'The zfs boot script has been split into the zfs-import,'
		einfo 'zfs-mount and zfs-share scripts.'
		einfo
		einfo 'You had the zfs script in your boot runlevel. For your'
		einfo 'convenience, it has been automatically removed and the three'
		einfo 'scripts that replace it have been configured to start.'
		einfo 'The zfs-import and zfs-mount scripts have been added to the boot'
		einfo 'runlevel while the zfs-share script is in the default runlevel.'

		rm "${EROOT}/etc/runlevels/boot/zfs"
		ln -snf "${EROOT}/etc/init.d/zfs-import" \
			"${EROOT}/etc/runlevels/boot/zfs-import"
		ln -snf "${EROOT}/etc/init.d/zfs-mount" \
			"${EROOT}/etc/runlevels/boot/zfs-mount"
		ln -snf "${EROOT}/etc/init.d/zfs-share" \
			"${EROOT}/etc/runlevels/default/zfs-share"
	else
		[[ -e "${EROOT}/etc/runlevels/boot/zfs-import" ]] || \
			einfo "You should add zfs-import to the boot runlevel."
		[[ -e "${EROOT}/etc/runlevels/boot/zfs-mount" ]]|| \
			einfo "You should add zfs-mount to the boot runlevel."
		[[ -e "${EROOT}/etc/runlevels/default/zfs-share" ]] || \
			einfo "You should add zfs-share to the default runlevel."
	fi

	if [[ -e "${EROOT}/etc/runlevels/default/zed" ]]; then
		einfo 'The downstream OpenRC zed script has replaced by the upstream'
		einfo 'OpenRC zfs-zed script.'
		einfo
		einfo 'You had the zed script in your default runlevel. For your'
		einfo 'convenience, it has been automatically removed and the zfs-zed'
		einfo 'script that replaced it has been configured to start.'

		rm "${EROOT}/etc/runlevels/boot/zed"
		ln -snf "${EROOT}/etc/init.d/zfs-zed" \
			"${EROOT}/etc/runlevels/default/zfs-zed"
	else
		[[ -e "${EROOT}/etc/runlevels/default/zfs-zed" ]] || \
			einfo "You should add zfs-zed to the default runlevel."
	fi

	if [[ -e "${EROOT}/etc/runlevels/shutdown/zfs-shutdown" ]]; then
		einfo "The zfs-shutdown script is obsolete. Removing it from runlevel."
		rm "${EROOT}/etc/runlevels/shutdown/zfs-shutdown"
	fi
}
