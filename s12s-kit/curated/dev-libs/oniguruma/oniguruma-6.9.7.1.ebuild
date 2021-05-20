# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools

DESCRIPTION="Regular expression library for different character encodings"
HOMEPAGE="https://github.com/kkos/oniguruma"
SRC_URI="https://github.com/kkos/${PN}/releases/download/v${PV}/onig-${PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0/5"
KEYWORDS="*"
IUSE="crnl-as-line-terminator static-libs"

BDEPEND=""
DEPEND=""
RDEPEND=""

S="${WORKDIR}/onig-$(ver_cut 1-3)"

DOCS=(AUTHORS HISTORY README{,_japanese} doc/{API,CALLOUTS.API,CALLOUTS.BUILTIN,FAQ,RE}{,.ja} doc/{SYNTAX.md,UNICODE_PROPERTIES})

src_prepare() {
	default
}

src_configure() {
	ECONF_SOURCE="${S}" econf \
		--enable-posix-api \
		$(use_enable crnl-as-line-terminator) \
		$(use_enable static-libs static)
}

src_install_all() {
	einstalldocs
	find "${ED}" -name "*.la" -delete || die
}
