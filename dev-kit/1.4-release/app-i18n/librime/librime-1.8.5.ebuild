# Distributed under the terms of the GNU General Public License v2
EAPI="7"

inherit cmake

DESCRIPTION="RIME (Rime Input Method Engine) core library"
HOMEPAGE="https://rime.im/ https://github.com/rime/librime"
SRC_URI="https://github.com/rime/librime/tarball/08dd95f5d9282346f0d4a3e8fc6b20811dc3d063 -> librime-1.8.5-08dd95f.tar.gz"

LICENSE="BSD"
SLOT="0/1-${PV}"
KEYWORDS="*"
IUSE="debug test"
RESTRICT="!test? ( test )"

BDEPEND="dev-libs/capnproto:0"
RDEPEND="app-i18n/opencc:0=
	>=dev-cpp/glog-0.3.5:0=
	dev-cpp/yaml-cpp:0=
	dev-libs/boost:0=[threads(+)]
	dev-libs/capnproto:0=
	dev-libs/leveldb:0=
	dev-libs/marisa:0="
DEPEND="${RDEPEND}
	dev-libs/darts
	dev-libs/utfcpp
	x11-base/xorg-proto
	test? ( dev-cpp/gtest )"

DOCS=(CHANGELOG.md README.md)

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/rime-librime-* "${S}"
}

src_configure() {
	local -x CXXFLAGS="${CXXFLAGS} -I${ESYSROOT}/usr/include/utf8cpp"

	if use debug; then
		CXXFLAGS+=" -DDCHECK_ALWAYS_ON"
	else
		CXXFLAGS+=" -DNDEBUG"
	fi

	local mycmakeargs=(
		-DBOOST_USE_CXX11=ON
		-DBUILD_TEST=$(usex test ON OFF)
		-DCMAKE_DISABLE_FIND_PACKAGE_Gflags=ON
		-DENABLE_EXTERNAL_PLUGINS=ON
		-DINSTALL_PRIVATE_HEADERS=ON
	)

	cmake_src_configure
}

pkg_postinst() {
	ewarn "Please update all packages installed using plum by running \"rime-install\"!"
	ewarn "Out of date packages might not work with an updated backend!"
}