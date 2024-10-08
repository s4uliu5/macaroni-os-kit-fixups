# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Library for overlaying text in X-Windows X-On-Screen-Display"
HOMEPAGE="https://sourceforge.net/projects/libxosd/"
SRC_URI="https://downloads.sourceforge.net/libxosd/libxosd/xosd-2.2.14/xosd-2.2.14.tar.gz -> xosd-2.2.14.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs xinerama"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXt
	media-fonts/font-misc-misc"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto"

DOCS=(
	AUTHORS ChangeLog NEWS README TODO
)

src_prepare() {
	default

	AT_M4DIR="${WORKDIR}"/m4 eautoreconf
}

src_configure() {
	econf \
		$(use_enable xinerama) \
		$(use_enable static-libs static)
}