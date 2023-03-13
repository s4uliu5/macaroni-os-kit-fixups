# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P=xdelta3-${PV}

DESCRIPTION="Computes changes between binary or text files and creates deltas"
HOMEPAGE="http://xdelta.org/"
SRC_URI="https://github.com/jmacd/xdelta-gpl/releases/download/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="*"
IUSE="examples lzma"

RDEPEND="lzma? ( app-arch/xz-utils:= )"
DEPEND="${RDEPEND}"

src_configure() {
	econf $(use_with lzma liblzma)
}

src_compile() {
	# avoid building tests
	emake xdelta3
}

src_install() {
	emake DESTDIR="${D}" install-binPROGRAMS install-man1
	dodoc draft-korn-vcdiff.txt README.md
	use examples && dodoc -r examples
}