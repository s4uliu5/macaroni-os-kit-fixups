# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Port of libtls from LibreSSL to OpenSSL"
HOMEPAGE="https://git.causal.agency/libretls/about/"
SRC_URI="https://causal.agency/libretls/${P}.tar.gz"

LICENSE="ISC"
SLOT="0/28"
KEYWORDS="*"

DEPEND="
	dev-libs/openssl:=
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	virtual/pkgconfig
"

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}