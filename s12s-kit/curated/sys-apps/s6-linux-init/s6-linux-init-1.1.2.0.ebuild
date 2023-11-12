# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Generates an init binary for s6-based init systems"
HOMEPAGE="https://www.skarnet.org/software/s6-linux-init/"
SRC_URI="https://www.skarnet.org/software/${PN}/${P}.tar.gz"

LICENSE="ISC"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="*"
IUSE="+sysv-utils"

RDEPEND="
	>=dev-lang/execline-2.9.4.0:=
	>=dev-libs/skalibs-2.14.0.0:=
	>=sys-apps/s6-2.12.0.0:=[execline]
	sysv-utils? (
		!sys-apps/openrc[sysv-utils(-)]
		!sys-apps/systemd[sysv-utils]
		!sys-apps/sysvinit
	)
"
DEPEND="${RDEPEND}"

HTML_DOCS=( doc/. )

src_prepare() {
	default

	# Avoid QA warning for LDFLAGS addition
	sed -i -e 's/.*-Wl,--hash-style=both$/:/' configure || die

	sed -i -e '/AR := /d' -e '/RANLIB := /d' Makefile || die
}

src_configure() {
	tc-export AR CC RANLIB

	local myconf=(
		--bindir=/bin
		--dynlibdir="/$(get_libdir)"
		--skeldir=/etc/s6-linux-init/skel
		--libdir="/usr/$(get_libdir)/${PN}"
		--libexecdir=/lib/s6
		--with-dynlib="/$(get_libdir)"
		--with-lib="/usr/$(get_libdir)/s6"
		--with-lib="/usr/$(get_libdir)/skalibs"
		--with-sysdeps="/usr/$(get_libdir)/skalibs"
		--enable-shared
		--disable-allstatic
		--disable-static
		--disable-static-libc
	)

	econf "${myconf[@]}"
}

src_install() {
	default

	if use sysv-utils ; then
		"${D}/bin/s6-linux-init-maker" -f "${D}/etc/s6-linux-init/skel" "${T}/dir" || die
		into /
		dosbin "${T}/dir/bin"/{halt,poweroff,reboot,shutdown,telinit}
	fi
}

pkg_postinst() {
	einfo "Read ${EROOT}/usr/share/doc/${PF}/html/quickstart.html"
	einfo "for usage instructions."
}