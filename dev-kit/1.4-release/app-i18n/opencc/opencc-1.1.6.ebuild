# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3+ )

inherit cmake python-any-r1

DESCRIPTION="Library for conversion between Traditional and Simplified Chinese characters"
HOMEPAGE="https://github.com/BYVoid/OpenCC"
SRC_URI="https://github.com/BYVoid/OpenCC/archive/refs/tags/ver.1.1.6.tar.gz -> opencc-1.1.6.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/1.1"
KEYWORDS="*"
IUSE="doc test"
RESTRICT="!test? ( test )"

BDEPEND="${PYTHON_DEPS}
	doc? ( app-doc/doxygen )"
DEPEND="dev-cpp/tclap
	dev-libs/darts
	dev-libs/marisa:0=
	dev-libs/rapidjson
	test? (
		dev-cpp/gtest
		!hppa? ( !sparc? ( dev-cpp/benchmark ) )
	)"
RDEPEND="dev-libs/marisa:0="

DOCS=(AUTHORS NEWS.md README.md)

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/OpenCC-* "${S}"
}

src_prepare() {
	rm -r deps || die
	cmake_src_prepare
	sed -e "s:\${DIR_SHARE_OPENCC}/doc:share/doc/${PF}:" -i doc/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DENABLE_BENCHMARK=$(if use test && has_version -d dev-cpp/benchmark; then echo ON; else echo OFF; fi)
		-DENABLE_GTEST=$(usex test ON OFF)
		-DUSE_SYSTEM_DARTS=ON
		-DUSE_SYSTEM_GOOGLE_BENCHMARK=ON
		-DUSE_SYSTEM_GTEST=ON
		-DUSE_SYSTEM_MARISA=ON
		-DUSE_SYSTEM_RAPIDJSON=ON
		-DUSE_SYSTEM_TCLAP=ON
	)

	cmake_src_configure
}
