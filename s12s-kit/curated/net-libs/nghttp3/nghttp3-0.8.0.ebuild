# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

SRC_URI="https://github.com/ngtcp2/nghttp3/releases/download/v${PV}/${P}.tar.xz"
KEYWORDS="*"

DESCRIPTION="HTTP/3 library written in C"
HOMEPAGE="https://github.com/ngtcp2/nghttp3/"

LICENSE="MIT"
SLOT="0/0"
IUSE="static-libs test"

BDEPEND="virtual/pkgconfig"
DEPEND="test? ( >=dev-util/cunit-2.1 )"
RDEPEND=""
RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DENABLE_LIB_ONLY=ON
		-DENABLE_STATIC_LIB=$(usex static-libs)
		-DENABLE_EXAMPLES=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_CUnit=$(usex !test)
	)
	cmake_src_configure
}

src_test() {
	cmake_build check
}
