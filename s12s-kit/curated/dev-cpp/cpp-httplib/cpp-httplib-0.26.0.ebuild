# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit cmake python-any-r1 toolchain-funcs

DESCRIPTION="C++ HTTP/HTTPS server and client library"
HOMEPAGE="https://github.com/yhirose/cpp-httplib/"

SRC_URI="https://github.com/yhirose/${PN}/archive/v${PV}.tar.gz
	-> ${P}.tar.gz"

KEYWORDS="*"

LICENSE="MIT"
SLOT="0/$(ver_cut 0-2)"  # soversion

IUSE="brotli -ssl test zlib zstd"
RESTRICT="!test? ( test )"

RDEPEND="
	brotli? (
		app-arch/brotli:=
	)
	ssl? (
		dev-libs/openssl
	)
	zlib? (
		sys-libs/zlib
	)
	zstd? (
		app-arch/zstd
	)
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

src_configure() {
	local -a mycmakeargs=(
		-DHTTPLIB_COMPILE=yes
		-DBUILD_SHARED_LIBS=yes
		-DHTTPLIB_USE_BROTLI_IF_AVAILABLE=no
		-DHTTPLIB_USE_OPENSSL_IF_AVAILABLE=no
		-DHTTPLIB_USE_ZLIB_IF_AVAILABLE=no
		-DHTTPLIB_USE_ZSTD_IF_AVAILABLE=no
		-DHTTPLIB_REQUIRE_BROTLI=$(usex brotli)
		-DHTTPLIB_REQUIRE_OPENSSL=$(usex ssl)
		-DHTTPLIB_REQUIRE_ZLIB=$(usex zlib)
		-DHTTPLIB_REQUIRE_ZSTD=$(usex zstd)
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

src_test() {
	cp -p -R --reflink=auto "${S}/test" ./test || die

	local -a failing_tests=(
		# Disable all online tests.
		"*.*_Online"

		# Fails on musl x86:
		ServerTest.GetRangeWithMaxLongLength
		ServerTest.GetStreamedWithTooManyRanges
	)

	# Little dance to please the GTEST filter (join array using ":").
	failing_tests_str="${failing_tests[@]}"
	failing_tests_filter="${failing_tests_str// /:}"

	# PREFIX is . to avoid calling "brew" and relying on stuff in /opt
	GTEST_FILTER="-${failing_tests_filter}" emake -C test \
		CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS} -I." PREFIX=.
}
