# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic

DESCRIPTION="Small, safe and fast formatting library"
HOMEPAGE="https://github.com/fmtlib/fmt"

SRC_URI="https://github.com/fmtlib/fmt/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"
S="${WORKDIR}/fmt-${PV}"

LICENSE="MIT"
SLOT="0/${PV}"
IUSE="test"
RESTRICT="!test? ( test )"

src_configure() {
	append-lfs-flags
	local mycmakeargs=(
		-DFMT_CMAKE_DIR="$(get_libdir)/cmake/fmt"
		-DFMT_LIB_DIR="$(get_libdir)"
		-DFMT_TEST=$(usex test)
	)
	cmake_src_configure
}
