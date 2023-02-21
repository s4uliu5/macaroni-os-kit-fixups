# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

SRC_URI="https://github.com/ngtcp2/ngtcp2/releases/download/v${PV}/${P}.tar.xz"
KEYWORDS="*"

DESCRIPTION="Implementation of the IETF QUIC Protocol"
HOMEPAGE="https://github.com/ngtcp2/ngtcp2/"

LICENSE="MIT"
SLOT="0/0"
IUSE="+gnutls openssl +ssl static-libs test"
REQUIRED_USE="ssl? ( || ( gnutls openssl ) )"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	ssl? (
		gnutls? ( >=net-libs/gnutls-3.7.2:0= )
		openssl? (
			>=dev-libs/openssl-1.1.1:0=
		)
	)"
DEPEND="${RDEPEND}
	test? ( >=dev-util/cunit-2.1 )"
RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DENABLE_STATIC_LIB=$(usex static-libs)
		-DENABLE_GNUTLS=$(usex gnutls)
		-DENABLE_OPENSSL=$(usex openssl)
		-DENABLE_BORINGSSL=OFF
		-DENABLE_PICOTLS=OFF
		-DENABLE_WOLFSSL=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_Libev=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_Libnghttp3=ON
	)
	cmake_src_configure
}

src_test() {
	cmake_build check
}
