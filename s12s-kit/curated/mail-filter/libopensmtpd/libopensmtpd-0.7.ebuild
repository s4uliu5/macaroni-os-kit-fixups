# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Library for creating OpenSMTPD filters"
HOMEPAGE="https://imperialat.at/dev/libopensmtpd/"
SRC_URI="https://imperialat.at/releases/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-libs/libevent"
RDEPEND="${DEPEND}"

src_prepare() {
	mv -f Makefile.gnu Makefile
	eapply_user
}

src_compile() {
	emake MANFORMAT="man"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" MANFORMAT="man" install
}
